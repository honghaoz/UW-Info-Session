#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
import re
import os
import jinja2
import json
import urllib
import urllib2

from google.appengine.ext import ndb
from google.appengine.ext import deferred
from google.appengine.api import memcache

import logging
import datetime
import sys
sys.path.insert(0, 'libs')
import pytz
import requests
from google.appengine.api import urlfetch
import functools

# Global variables for jinja environment
template_dir = os.path.join(os.path.dirname(__file__), 'html_template')
jinja_env = jinja2.Environment(loader = jinja2.FileSystemLoader(template_dir), autoescape = True)

# Basic Handler
class BasicHandler(webapp2.RequestHandler):
    # rewrite the write, more neat
    def write(self, *a, **kw):
        self.response.write(*a, **kw)
    # render helper function, use jinja2 to get template
    def render_str(self, template, **params):
        t = jinja_env.get_template(template)
        return t.render(params)
    # render page using jinja2
    def render(self, template, **kw):
        self.write(self.render_str(template, **kw))

class MainHandler(BasicHandler):
    """Handle for '/' """
    def get(self):
        self.render('home.html')

#=========================================================
# base url
#CECA_URL = "http://www.ceca.uwaterloo.ca/students/sessions_details.php?id=%s" # Old URL
CECA_URL = "http://www.ceca.uwaterloo.ca/students/sessions.php?month_num=%(month)s&year_num=%(year)s"# % {'month': '1', 'year': '2'}
info_session_url = "http://www.ceca.uwaterloo.ca/students/sessions_details.php?id=%(id)s"# % {'id': '5000'}
cache_duration = 60 * 60 * 24 * 20 # 20 days experiation
fetch_deadline = 10

# sessions list
sessions = []
numbers = []
fetching_months = {}

# messy regex scraping was required. see source of above page for more info. :(
# global functions
def get_by_label(label, html):
    # regex is very slow if it doesn't exist (too many wildcards); prevent that.
    if label in html:
        return re.findall("<td.*?>%s </td>.*?<td.*?>(.*?)</td>" % label, html, re.DOTALL)
    else:
        return []

def get_others(html):
    # [audience, br, br, programms, descriptions]
    return re.findall('<tr><td width="60%" colspan="2"><i>For (.+?(<br />|<br>).+?)(<br />|<br>)(.*?)</i></td></tr>.+?<tr><td width="60%" colspan="2"><i>(.*?)</i></td></tr>', html, re.DOTALL)

def get_ids(html):
    return re.findall('<a href="sessions_details.php\?id=(\d+)"', html)

def parse_link(html):
    link = re.findall('<a href="(.+?)".*?>', html)[0]
    if link == "http://": # this is the default on the ceca site when no url is entered
        link = ""
    return link

def parse_time(html):
    return html.split(" - ")

# listOfMonths: [(2017, 5), (2017, 6), (2017, 7), (2017, 8)]
def renderResponse(year_months):
    urlfetch.set_default_fetch_deadline(fetch_deadline)
    sessions = [] # stores a list of info session dicts
    numbers = [] # stores numbers of events for months. Aka months

    session_rpcs = []
    def process_session(session_id):
        session = memcache.get(session_id)
        if session is not None:
            # logging.info("found id: %s" % session_id)
            sessions.append(session)
            return
        else:
            session_url = info_session_url % {'id': session_id}
            # logging.info("request id: %s" % session_id)
            def handle_result(rpc, session_id):
                session_html = rpc.get_result().content

                def parse_session(session_html):
                    employer = get_by_label("Employer:", session_html)
                    employer = employer[0] if len(employer) > 0 else ""
                    date = get_by_label("Date:", session_html)
                    date = date[0] if len(date) > 0 else ""
                    time = map(parse_time, get_by_label("Time:", session_html))
                    time = time[0] if len(time) > 0 else ""
                    location = get_by_label("Location:", session_html)
                    location = location[0] if len(location) > 0 else ""
                    website = map(parse_link, get_by_label("Web Site:", session_html))
                    website = website[0] if len(website) > 0 else ""
                    other = get_others(session_html)
                    other = other[0] if len(other) > 0 else ("", "", "", "", "")

                    session = {}
                    session["id"] = int(session_id)
                    session["employer"] = unicode(employer.strip(), errors = 'ignore')
                    # logging.info("employer: %s" % session["employer"])
                    session["date"] = unicode(date.strip(), errors = 'ignore')
                    # logging.info("date: %s" % session["date"])
                    session["start_time"] = unicode(time[0].strip(), errors = 'ignore')
                    # logging.info("start_time: %s" % session["start_time"])
                    session["end_time"] = unicode(time[1].strip(), errors = 'ignore')
                    # logging.info("end_time: %s" % session["end_time"])
                    session["location"] = unicode(location.strip(), errors = 'ignore')
                    # logging.info("location: %s" % session["location"])
                    session["website"] = unicode(website.strip(), errors = 'ignore')
                    # logging.info("website: %s" % session["website"])
                    session["audience"] = unicode(other[0].replace('<br/>', ' ').replace('<br />', ' ').replace('<br>', ' ').strip(), errors = 'ignore')
                    # logging.info("audience: %s" % session["audience"])
                    session["programs"] = unicode(other[3].strip(), errors = 'ignore')
                    # logging.info("programs: %s" % session["programs"])
                    session["description"] = unicode(other[4].replace('</p>', '').replace('<p>', '').replace('<br/>', ' ').replace('<br />', ' ').replace('<br>', ' ').replace('</br>', ' ').strip(), errors = 'ignore')
                    # logging.info("description: %s" % session["description"])

                    return session

                # logging.info("done request id: %s" % session_id)
                session = parse_session(session_html)

                # Clean cached info session
                existing_session = memcache.get(session_id)
                if existing_session is not None:
                    # logging.info("session id: %s exists, delete..." % session_id)
                    memcache.delete(session_id)
                memcache.add(session_id, session, cache_duration)
                sessions.append(session)

            rpc = urlfetch.create_rpc()
            rpc.callback = functools.partial(handle_result, rpc, session_id)
            urlfetch.make_fetch_call(rpc, session_url)

            session_rpcs.append(rpc)

    month_rpcs = []
    def process_month(year, month):
        month_url = CECA_URL % {'month': month, 'year': year}

        def handle_result(rpc, year_month):
            # logging.info("Processing: %s" % str(year_month))
            month_html = rpc.get_result().content
            ids = get_ids(month_html)
            for id in ids:
                process_session(id)

            number = {}
            number["month"] = yearMonthString(year_month)
            number["ids"] = len(ids)
            number["employers"] = len(ids)
            number["date"] = len(ids)
            number["times"] = len(ids)
            number["locations"] = len(ids)
            number["websites"] = len(ids)
            number["others"] = len(ids)
            numbers.append(number)

            for rpc in session_rpcs:
                rpc.wait()

        rpc = urlfetch.create_rpc()
        rpc.callback = functools.partial(handle_result, rpc, (year, month))
        urlfetch.make_fetch_call(rpc, month_url)

        month_rpcs.append(rpc)

    # Start
    for (year, month) in year_months:
        process_month(year, month)

    # Waiting for completion
    for rpc in month_rpcs:
        rpc.wait()

    # logging.info('Done')

    # add data to response dict
    response = {}
    response["meta"] = {"months" : numbers}
    response["data"] = sessions
    return response

# Wants to fetch months, fliter out currently fetching months
def fetch_months_in_background(months):
    months_to_fetch = []
    for year_month in months:
        if not year_month in fetching_months:
            months_to_fetch.append(year_month)

    if len(months_to_fetch) > 0:
        deferred.defer(fetchDataInBackground, months_to_fetch)

# listOfMonths: [(2017, 5), (2017, 6), (2017, 7), (2017, 8)]
def fetchDataInBackground(year_months):
    logging.info("Fetching %(year_months)s in background..." % {'year_months': year_months})

    urlfetch.set_default_fetch_deadline(fetch_deadline)

    session_rpcs = []
    def process_session(session_id):
        session_url = info_session_url % {'id': session_id}

        def handle_result(rpc, session_id):
            session_html = rpc.get_result().content

            def parse_session(session_html):
                employer = get_by_label("Employer:", session_html)
                employer = employer[0] if len(employer) > 0 else ""
                date = get_by_label("Date:", session_html)
                date = date[0] if len(date) > 0 else ""
                time = map(parse_time, get_by_label("Time:", session_html))
                time = time[0] if len(time) > 0 else ""
                location = get_by_label("Location:", session_html)
                location = location[0] if len(location) > 0 else ""
                website = map(parse_link, get_by_label("Web Site:", session_html))
                website = website[0] if len(website) > 0 else ""
                other = get_others(session_html)
                other = other[0] if len(other) > 0 else ("", "", "", "", "")

                session = {}
                session["id"] = int(session_id)
                session["employer"] = unicode(employer.strip(), errors = 'ignore')
                # logging.info("employer: %s" % session["employer"])
                session["date"] = unicode(date.strip(), errors = 'ignore')
                # logging.info("date: %s" % session["date"])
                session["start_time"] = unicode(time[0].strip(), errors = 'ignore')
                # logging.info("start_time: %s" % session["start_time"])
                session["end_time"] = unicode(time[1].strip(), errors = 'ignore')
                # logging.info("end_time: %s" % session["end_time"])
                session["location"] = unicode(location.strip(), errors = 'ignore')
                # logging.info("location: %s" % session["location"])
                session["website"] = unicode(website.strip(), errors = 'ignore')
                # logging.info("website: %s" % session["website"])
                session["audience"] = unicode(other[0].replace('<br/>', ' ').replace('<br />', ' ').replace('<br>', ' ').strip(), errors = 'ignore')
                # logging.info("audience: %s" % session["audience"])
                session["programs"] = unicode(other[3].strip(), errors = 'ignore')
                # logging.info("programs: %s" % session["programs"])
                session["description"] = unicode(other[4].replace('</p>', '').replace('<p>', '').replace('<br/>', ' ').replace('<br />', ' ').replace('<br>', ' ').replace('</br>', ' ').strip(), errors = 'ignore')
                # logging.info("description: %s" % session["description"])

                return session

            session = parse_session(session_html)
            # Clean cached info session
            existing_session = memcache.get(session_id)
            if existing_session is not None:
                # logging.info("session id: %s exists, delete..." % session_id)
                memcache.delete(session_id)
            # logging.info("add session id: %s" % session_id)
            memcache.add(session_id, session, cache_duration)
            sessions.append(session)

        rpc = urlfetch.create_rpc()
        rpc.callback = functools.partial(handle_result, rpc, session_id)
        urlfetch.make_fetch_call(rpc, session_url)

        session_rpcs.append(rpc)

    month_rpcs = []
    def process_month(year, month):
        month_url = CECA_URL % {'month': month, 'year': year}

        def handle_result(rpc, year_month):
            # logging.info("Processing: %s" % str(year_month))
            month_html = rpc.get_result().content
            ids = get_ids(month_html)
            for id in ids:
                process_session(id)

            for rpc in session_rpcs:
                rpc.wait()

            fetching_months.pop((year, month), None)
            logging.info("Fetching %(year)s, %(month)s in background... Completed" % {'year': year, 'month': month})

        rpc = urlfetch.create_rpc()
        rpc.callback = functools.partial(handle_result, rpc, (year, month))
        urlfetch.make_fetch_call(rpc, month_url)

        month_rpcs.append(rpc)

    # Start
    for (year, month) in year_months:
        fetching_months[(year, month)] = True
        process_month(year, month)

    # Waiting for completion
    for rpc in month_rpcs:
        rpc.wait()

# get term string from year and month, eg: 2014Jan -> 2014 Winter
def getTermFromYearMonth(theMonthId):
    year = theMonthId[:4]
    month = theMonthId[4:]
    if month == 'Jan' or month == 'Feb' or month == 'Mar' or month == 'Apr':
        return year + " Winter"
    elif month == 'May' or month == 'Jun' or month == 'Jul' or month == 'Aug':
        return year + " Spring"
    else:
        return year + " Fall"

# get current term string
def getCurrentTerm():
    timezone = pytz.timezone('EST')
    currentDate = datetime.datetime.now(timezone)
    # logging.info(currentDate.strftime("%Y%b"))
    currentTerm = getTermFromYearMonth(currentDate.strftime("%Y%b"))
    return currentTerm

# 2017Spring -> [2017May, 2017Jun, 2017Jul, 2017Aug]
# 2017Spring -> [(2017, 5), (2017, 6), (2017, 7), (2017, 8)]
def getMonthsOfTerm(theTerm):
    year, term = theTerm.split(" ")
    year = year.strip()
    term = term.strip()
    result = []
    if term == 'Winter':
        result = [(year, 1), (year, 2), (year, 3), (year, 4)]
    elif term == 'Spring':
        result = [(year, 5), (year, 6), (year, 7), (year, 8)]
    elif term == 'Fall':
        result = [(year, 9), (year, 10), (year, 11), (year, 12)]
    else:
        result = []
    return result

# (2017, 5) -> 2017May
def yearMonthString(year_month):
    year, month = year_month
    if month == 1:
        return "%sJan" % year
    elif month == 2:
        return "%sFeb" % year
    elif month == 3:
        return "%sMar" % year
    elif month == 4:
        return "%sApr" % year
    elif month == 5:
        return "%sMay" % year
    elif month == 6:
        return "%sJun" % year
    elif month == 7:
        return "%sJul" % year
    elif month == 8:
        return "%sAug" % year
    elif month == 9:
        return "%sSep" % year
    elif month == 10:
        return "%sOct" % year
    elif month == 11:
        return "%sNov" % year
    elif month == 12:
        return "%sDec" % year
    else:
        return ""

class Keys(ndb.Model):
    number_of_keys = ndb.IntegerProperty(required = True)
    totoal_uses = ndb.IntegerProperty(required = True)
    created_time = ndb.DateTimeProperty(auto_now_add = True)
    last_modified = ndb.DateTimeProperty(auto_now = True)
class aKey(ndb.Model):
    uses = ndb.IntegerProperty(required = True)
    created_time = ndb.DateTimeProperty(auto_now_add = True)
    last_modified = ndb.DateTimeProperty(auto_now = True)

class setNumberOfKeys(BasicHandler):
    """json format one month"""
    def get(self):
        num = int(self.request.get("num"))
        logging.info('set num of keys: %d', num)
        alreadyExistedKeys = Keys.get_by_id(1000)
        totoal_uses = 0
        if alreadyExistedKeys == None:
            logging.info("create")
            totoal_uses = 0
            Keys(id = 1000, number_of_keys = num, totoal_uses = totoal_uses).put()
        else :
            logging.info("update")
            alreadyExistedKeys.number_of_keys = num
            alreadyExistedKeys.put()
            # totoal_uses = alreadyExistedKeys.totoal_uses
        # Keys(id = 1000, number_of_keys = num, totoal_uses = totoal_uses).put()
        # add new key
        logging.info("add new aKey: %d", num)
        aKey(id = num, uses = 0).put()

# PRE: Keys exists
def getMaxNumberOfKeys():
    # queryURL = "http://uw-info.appspot.com/get_number_of_keys"
    # queryResult = urllib2.urlopen(queryURL).read()
    # jsonResult = json.loads(queryResult)
    # return int(jsonResult['number_of_keys'])
    alreadyExistedKeys = Keys.get_by_id(1000)
    if not alreadyExistedKeys == None:
        return alreadyExistedKeys.number_of_keys
    else :
        logging.error("getMaxNumberOfKeys error: Keys is not queried")
        return 0

def logKeyUsage(key):
    alreadyExistedKeys = Keys.get_by_id(1000)
    if not alreadyExistedKeys == None:
        alreadyExistedKeys.totoal_uses += 1
        alreadyExistedKeys.put()
        #Keys(id = 1000, number_of_keys = alreadyExistedKeys.number_of_keys, totoal_uses = alreadyExistedKeys.totoal_uses + 1).put()
    else :
        logging.error("logKeyUsage error: Keys is not queried")
    existAKey = aKey.get_by_id(key)
    if existAKey == None:
        logging.error("logKeyUsage error: aKey is not queried")
        aKey(id = key, uses = 1).put()
        logging.error("Key: %d, Uses: %d", key, 1)
    else:
        newUses = existAKey.uses + 1
        existAKey.uses = newUses
        existAKey.put()
        #aKey(id = key, uses = newUses).put()
        logging.info("Key: %d, Uses: %d", key, newUses)

# def getKeyUsage():
    #queryURL = "http://uw-info.appspot.com/logkey"
    #urllib2.urlopen(queryURL + '?key=' + str(key))


class JsonOneMonth(BasicHandler):
    """json format one month"""
    def get(self, monthId):
        key = int(self.request.get("key"))
        self.response.headers["Content-Type"] = "application/json"
        if key <= getMaxNumberOfKeys():
            response = renderResponse([monthId])
            response['meta']['term'] = getTermFromYearMonth(monthId)
            logKeyUsage(key)
            self.write(json.dumps(response))
        else:
            self.write(json.dumps(renderResponse([])))

class JsonOneTerm(BasicHandler):
    """json format one term"""
    def get(self, theTerm):
        year = theTerm[:4]
        term = theTerm[4:]
        key = int(self.request.get("key"))
        self.response.headers["Content-Type"] = "application/json"

        months = getMonthsOfTerm(year + " " + term)

        # if key <= getMaxNumberOfKeys():
        response = renderResponse(months)
        response['meta']['term'] = year + " " + term
        # logKeyUsage(key)
        self.write(json.dumps(response))

        fetch_months_in_background(months)
        # months_to_fetch = []
        # for year_month in months:
        #     if not year_month in fetching_months:
        #         months_to_fetch.append(year_month)
        #
        # if len(months_to_fetch) > 0:
        #     deferred.defer(fetchDataInBackground, months_to_fetch)
        #     return

        # elif key == 'text':
        #     self.response.headers["Content-Type"] = "text/html"
        #     self.write('Text web page, used for test')
        # elif key == '503error':
        #     self.response.set_status(503)
        #     self.write('error, code: 503')
        # else:
        #     self.write(json.dumps(renderResponse([])))

class Json(BasicHandler):
    """json format"""
    def get(self):
        key = int(self.request.get("key"))
        self.response.headers["Content-Type"] = "application/json"
        if key <= getMaxNumberOfKeys():
            currentTerm = getCurrentTerm()
            response = renderResponse(getMonthsOfTerm(currentTerm))
            # From here, response contains
            # {"data" : [{
            #           "audience": "Co-op and Graduating Students",
            #           "date": "May 6, 2014",
            #           "description": "",
            #           "employer": "Enflick",
            #           "end_time": "1:30 PM",
            #           "id": "",
            #           "location": "TC 2218",
            #           "programs": "ALL - MATH faculty, ALL - ENG faculty",
            #           "start_time": "11:30 AM",
            #           "website": ""
            #           }, {} ...],
            #   "meta" : {"months": [],
            #             "term" : "2014 Spring"}}
            response['meta']['term'] = currentTerm
            logKeyUsage(key)
            self.write(json.dumps(response))
        else:
            self.write(json.dumps(renderResponse([])))

class getKeyUsage(BasicHandler):
    def get(self):
        #aKeys = ndb.gql("SELECT * FROM aKey")
        aKeys = aKey.query()
        usage = []
        for each in aKeys.iter():
            #logging.info(each.key.id())
            usage.append({"key" : str(each.key.id()), "uses" : each.uses})
        self.write(json.dumps({'usage': usage, 'status' : 'valid'}))

# Parse related
def createParseInfoSessionObject(infoSessionDictionary):
    try:
        connection = httplib.HTTPSConnection('api.parse.com', 443)
        connection.connect()
        connection.request('POST', '/1/classes/InfoSession', json.dumps(infoSessionDictionary), {
               "X-Parse-Application-Id": "zytbQR05vLnq2h37zHHBDneLWMzaH47qHB978zfx",
               "X-Parse-REST-API-Key": "93OVEHh2zAc1tz7HIlOENOQJWuB05s1vOXd4KdjB",
               "Content-Type": "application/json"
             })
        result = json.loads(connection.getresponse().read())
        logging.info(result)
    except:
        logging.error("create an object failed")
        return False
    return True

parseReUpdateTimes = 0

# Test code
# testTime = 0

def commitUpdateParse():
    if parseReUpdateTimes > 3:
        logging.error("Update Parse more than 3 times")
        return False
    global parseReUpdateTimes
    parseReUpdateTimes += 1
    logging.info("Re update Parse objects")

    try:
        # Clean out old data
        # 1: Collecting objectIds
        try:
            connection = httplib.HTTPSConnection('api.parse.com', 443)
            params = urllib.urlencode({"keys":"", "limit":1000})
            connection.connect()
            connection.request('GET', '/1/classes/InfoSession?%s' % params, '', {
                   "X-Parse-Application-Id": "zytbQR05vLnq2h37zHHBDneLWMzaH47qHB978zfx",
                   "X-Parse-REST-API-Key": "93OVEHh2zAc1tz7HIlOENOQJWuB05s1vOXd4KdjB"
                 })
            result = json.loads(connection.getresponse().read())
            objectIdsToBeDeleted = []
            for e in result["results"]:
                objectIdsToBeDeleted.append(e["objectId"])
        except:
            logging.error("Get objectIds failed")
            return commitUpdateParse()

        logging.info("To delete " + str(len(objectIdsToBeDeleted)) + " objects")

        # 2: Construct delete diction
        requestDictionary = {}
        requestDictionary["requests"] = []

        # restNumberToBeDeleted = len(objectIdsToBeDeleted)
        while len(objectIdsToBeDeleted) > 0:
            logging.info(len(objectIdsToBeDeleted))
            requestDictionary["requests"] = []
            # Delete 50 objects in batch
            deletedEntryNumber = 0
            for i in range(0, 50):
                try:
                    deleteRequest = {}
                    deleteRequest["method"] = "DELETE"
                    deleteRequest["path"] = "/1/classes/InfoSession/%s" % objectIdsToBeDeleted[i]
                except:
                    deletedEntryNumber = i
                    break
                requestDictionary["requests"].append(deleteRequest)
                deletedEntryNumber = 50;

            # 3: Delete 50 entries
            connection = httplib.HTTPSConnection('api.parse.com', 443)
            connection.connect()
            connection.request('POST', '/1/batch', json.dumps(requestDictionary), {
                   "X-Parse-Application-Id": "zytbQR05vLnq2h37zHHBDneLWMzaH47qHB978zfx",
                   "X-Parse-REST-API-Key": "93OVEHh2zAc1tz7HIlOENOQJWuB05s1vOXd4KdjB",
                   "Content-Type": "application/json"
                 })
            result = json.loads(connection.getresponse().read())
            logging.info(result)
            objectIdsToBeDeleted = objectIdsToBeDeleted[deletedEntryNumber:]
    except:
        logging.error("Delete Parse Object Failed")
        return commitUpdateParse()

    logging.info("Delete Parse Object Succeed!")

    # Store new data
    currentTerm = getCurrentTerm()
    response = renderResponse(getMonthsOfTerm(currentTerm))
    # From here, response contains
    # {"data" : [{
    #           "audience": "Co-op and Graduating Students",
    #           "date": "May 6, 2014",
    #           "description": "",
    #           "employer": "Enflick",
    #           "end_time": "1:30 PM",
    #           "id": "",
    #           "location": "TC 2218",
    #           "programs": "ALL - MATH faculty, ALL - ENG faculty",
    #           "start_time": "11:30 AM",
    #           "website": ""
    #           }, {} ...],
    #   "meta" : {"months": [],
    #             "term" : "2014 Spring"}}
    # Store Objects in Parse

    global testTime

    sum = 0
    for eachInfoSessionDic in response["data"]:
        infoSessionId = eachInfoSessionDic["id"]
        eachInfoSessionDic.pop("id", None)
        eachInfoSessionDic["info_session_id"] = infoSessionId

        # Test code
        # if sum == 10 and testTime == 0:
        #     testTime += 1
        #     logging.error("Test Create Parse Object Failed")
        #     return commitUpdateParse()

        if not createParseInfoSessionObject(eachInfoSessionDic):
            logging.error("Create Parse Object Failed")
            return commitUpdateParse()
        sum += 1
    logging.info("Parse updated: %d" % sum)
    return True

class UpdateParse(BasicHandler):
    def get(self):
        key = int(self.request.get("key"))
        if key <= getMaxNumberOfKeys():
            global parseReUpdateTimes
            parseReUpdateTimes = 0
            result = commitUpdateParse()
            if result:
                self.write("Parse updated successfully")
            else:
                self.write("Parse updated failed")
        else:
            self.write("Invalid key")

class fetchData(BasicHandler):
    def get(self):
        currentTerm = getCurrentTerm()
        months = getMonthsOfTerm(currentTerm)
        self.write(currentTerm)

        fetch_months_in_background(months)

app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/get_key_usage', getKeyUsage),
    ('/set_number_of_keys', setNumberOfKeys),
    ('/infosessions/([0-9]{4}[A-Z]{1}[a-z]{2}).json', JsonOneMonth),
    ('/infosessions/([0-9]{4}[A-Z]{1}[a-z]+).json', JsonOneTerm),
    ('/infosessions.json', Json),
    ('/updateParse', UpdateParse),
    ('/fetch_data', fetchData)
], debug=False)
