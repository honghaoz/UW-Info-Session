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
from google.appengine.api import memcache

import logging
import datetime
import sys
sys.path.insert(0, 'libs')
import pytz

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
CECA_URL = "http://www.ceca.uwaterloo.ca/students/sessions_details.php?id=%s"
# sessions list
sessions = []
numbers = []

# messy regex scraping was required. see source of above page for more info. :(
# global functions
def get_by_label(label, html):
    # regex is very slow if it doesn't exist (too many wildcards); prevent that.
    if label in html:
        return re.findall("<td.*?>%s </td>.*?<td.*?>(.*?)</td>"%label, html, re.DOTALL)
    else:
        return []

def get_others(html):
    return re.findall('<tr><td width="60%" colspan="2"><i>For (.+?) - (.*?)</i></td></tr>.+?<tr><td width="60%" colspan="2"><i>(.*?)</i></td></tr>', html, re.DOTALL)

def get_ids(html):
    return re.findall('<a href=".+id=(\d+).+?">RSVP \(students\)</a>', html)

def parse_link(html):
    link = re.findall('<a href="(.+?)".*?>', html)[0]
    if link == "http://": # this is the default on the ceca site when no url is entered
        link = ""
    return link

def parse_time(html):
    return html.split(" - ")

def renderResponse(listOfMonths):
    sessions = []
    numbers = []
    for month in listOfMonths:
        try:
            html = urllib2.urlopen(CECA_URL%month).read()
        except urllib2.HTTPError, e:
            logging.error('render CECA_URL error: Exception thrown')
            logging.error(e.code)
            logging.error(e.msg)
            logging.error(e.headers)
            logging.error(e.fp.read())
        logging.info(month)
        # find all the fields individually. note the order matters.
        ids = get_ids(html)
        #logging.info("ids: %s" % len(ids))

        employers = get_by_label("Employer:", html)
        #logging.info("employers: %s" % len(employers))

        dates = get_by_label("Date:", html)
        #logging.info("dates: %s" % len(dates))

        times = map(parse_time, get_by_label("Time:", html))
        #logging.info("times: %s" % len(times))

        locations = get_by_label("Location:", html)
        #logging.info("locations: %s" % len(locations))

        websites = map(parse_link, get_by_label("Web Site:", html))
        #logging.info("websites: %s" % len(websites))

        others = get_others(html)
        #logging.info("others: %s" % len(others))

        # make sure each session has all the required fields
        if not (len(employers) == len(dates) == len(times) == len(locations) == len(websites) == len(others)):
            raise Exception, 'Some sessions are missing info'

        # merge/zipper all the fields together per info sessions
        idOffset = len(employers) - len(ids)
        for i in range(0, len(employers)):
            session = {}
            if i < idOffset:
                session["id"] = ""
            else:
                session["id"] = ids[i - idOffset]
            #logging.info("#: %s" % str(i))
            session["employer"] = unicode(employers[i], errors = 'ignore')
            #logging.info("employer: %s" % session["employer"])
            session["date"] = unicode(dates[i], errors = 'ignore')
            #logging.info("date: %s" % session["date"])
            session["start_time"] = unicode(times[i][0], errors = 'ignore')
            #logging.info("start_time: %s" % session["start_time"])
            session["end_time"] = unicode(times[i][1], errors = 'ignore')
            #logging.info("end_time: %s" % session["end_time"])
            session["location"] = unicode(locations[i], errors = 'ignore')
            #logging.info("location: %s" % session["location"])
            session["website"] = unicode(websites[i], errors = 'ignore')
            #logging.info("website: %s" % session["website"])
            session["audience"] = unicode(others[i][0], errors = 'ignore')
            #logging.info("audience: %s" % session["audience"])
            session["programs"] = unicode(others[i][1], errors = 'ignore')
            #logging.info("programs: %s" % session["programs"])
            session["description"] = unicode(others[i][2].replace('</p>', '').replace('<br/>', '\n'), errors = 'ignore')
            #logging.info("description: %s" % session["description"])
            sessions.append(session)

        number = {}
        number["month"] = month
        number["ids"] = str(len(ids))
        number["employers"] = str(len(employers))
        number["date"] = str(len(dates))
        number["times"] = str(len(times))
        number["locations"] = str(len(locations))
        number["websites"] = str(len(websites))
        number["others"] = str(len(others))
        numbers.append(number)

    # add data to response dict
    response = {}
    response["meta"] = {"months" : numbers}
    response["data"] = sessions
    return response

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
    logging.info(currentDate.strftime("%Y%b"))
    currentTerm = getTermFromYearMonth(currentDate.strftime("%Y%b"))
    return currentTerm

def getMonthsOfTerm(theTerm):
    year, term = theTerm.split(" ")
    year = year.strip()
    term = term.strip()
    result = []
    if term == 'Winter':
        result = [year + 'Jan', year + 'Feb', year + 'Mar', year + 'Apr']
    elif term == 'Spring':
        result = [year + 'May', year + 'Jun', year + 'Jul', year + 'Aug']
    elif term == 'Fall':
        result = [year + 'Sep', year + 'Oct', year + 'Nov', year + 'Dec']
    else:
        result = []
    return result


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
        if key <= getMaxNumberOfKeys():
            response = renderResponse(getMonthsOfTerm(year + " " + term))
            response['meta']['term'] = year + " " + term
            logKeyUsage(key)
            self.write(json.dumps(response))
        # elif key == 'text':
        #     self.response.headers["Content-Type"] = "text/html"
        #     self.write('Text web page, used for test')
        # elif key == '503error':
        #     self.response.set_status(503)
        #     self.write('error, code: 503')
        else:
            self.write(json.dumps(renderResponse([])))

class Json(BasicHandler):
    """json format"""
    def get(self):
        key = int(self.request.get("key"))
        self.response.headers["Content-Type"] = "application/json"
        if key <= getMaxNumberOfKeys():
            currentTerm = getCurrentTerm()
            response = renderResponse(getMonthsOfTerm(currentTerm))
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

app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/get_key_usage', getKeyUsage),
    ('/set_number_of_keys', setNumberOfKeys),
    ('/infosessions/([0-9]{4}[A-Z]{1}[a-z]{2}).json', JsonOneMonth),
    ('/infosessions/([0-9]{4}[A-Z]{1}[a-z]+).json', JsonOneTerm),
    ('/infosessions.json', Json)
], debug=True)