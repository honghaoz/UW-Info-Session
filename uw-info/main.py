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
        html = urllib2.urlopen(CECA_URL%month).read()

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
    response["meta"] = {"numbers" : numbers}
    response["data"] = sessions
    return response

class JsonOneMonth(BasicHandler):
    """json format one month"""
    def get(self, monthId):
        key = self.request.get("key")
        if key == '77881122':
            self.write(json.dumps(renderResponse([monthId])))
        else:
            self.write(json.dumps(renderResponse([])))

class Json(BasicHandler):
    """json format"""
    def get(self):
        key = self.request.get("key")
        self.response.headers["Content-Type"] = "application/json"
        if key == '77881122':
            response = urllib2.urlopen("http://uw-info1.appspot.com/infosessions.json?key=77881122").read()
            self.write(response)
        else:
            self.write(json.dumps(renderResponse([])))

class Keys(ndb.Model):
    number_of_keys = ndb.IntegerProperty(required = True)
    totoal_uses = ndb.IntegerProperty(required = True)
    created_time = ndb.DateTimeProperty(auto_now_add = True)
    last_modified = ndb.DateTimeProperty(auto_now = True)

class aKey(ndb.Model):
    uses = ndb.IntegerProperty(required = True)
    created_time = ndb.DateTimeProperty(auto_now_add = True)
    last_modified = ndb.DateTimeProperty(auto_now = True)

class GetKey(BasicHandler):
    def get(self):
        key = self.request.get("key")
        self.response.headers["Content-Type"] = "application/json"
        if key == '77881122':
            newKey = 0
            # get the only one Keys DB, if not exists, creat one
            alreadyExistedKeys = Keys.get_by_id(1000)
            if alreadyExistedKeys == None:
                logging.info("create")
                Keys(id = 1000, number_of_keys = 1, totoal_uses = 0).put()
                newKey = 1
                updateNumberOfKeys(newKey)
                logging.info("Key: %d", newKey)
            else :
                logging.info("update")
                newKey = alreadyExistedKeys.number_of_keys + 1
                alreadyExistedKeys.number_of_keys = newKey
                alreadyExistedKeys.put()
                #Keys(id = 1000, number_of_keys = newKey, totoal_uses = totoal_uses).put()
                updateNumberOfKeys(newKey)
                logging.info("Key: %d", newKey)
            response = {"key" : newKey, "status" : "valid"}
            self.write(json.dumps(response))
        else:
            response = {'key': 0, "status" : "invalid"}
            self.write(json.dumps(response))

# PRE: Keys must exist one
class Logkey(BasicHandler):
    def get(self):
        key = int(self.request.get("key"))
        alreadyExistedKeys = Keys.get_by_id(1000)
        Keys(id = 1000, number_of_keys = alreadyExistedKeys.number_of_keys, totoal_uses = alreadyExistedKeys.totoal_uses + 1).put()
        existAKey = aKey.get_by_id(key)
        if existAKey == None:
            aKey(id = key, uses = 1).put()
            logging.info("Key: %d, Uses: %d", key, 1)
        else:
            newUses = existAKey.uses + 1
            aKey(id = key, uses = newUses).put()
            logging.info("Key: %d, Uses: %d", key, newUses)


class getNumberOfKeys(BasicHandler):
    def get(self):
        alreadyExistedKeys = Keys.get_by_id(1000)
        if alreadyExistedKeys == None:
            response = {"number_of_keys" : 0}
            self.write(json.dumps(response))
        else :
            response = {"number_of_keys" : alreadyExistedKeys.number_of_keys}
            self.write(json.dumps(response))

def updateNumberOfKeys(number_of_keys):
    queryURL1 = "http://uw-info1.appspot.com/set_number_of_keys?num=" + str(number_of_keys)
    #queryURL2 = "http://uw-info2.appspot.com/set_number_of_keys?num=" + str(number_of_keys)
    urllib2.urlopen(queryURL1)
    #urllib2.urlopen(queryURL2)

app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/getkey', GetKey),
    ('/logkey', Logkey),
    ('/get_number_of_keys', getNumberOfKeys),
    ('/infosessions/([0-9]{4}[A-Z]{1}[a-z]{2}).json', JsonOneMonth),
    ('/infosessions.json', Json)
], debug=True)
