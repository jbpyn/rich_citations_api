Todos
==============
* Ad copyright text
* Upgrade to Rails 4.2
* Add API versioining
  - Make sure that Vary header includes whatever we choose
  - Add version as a response header
* PUT changes
* PUT/GET with a path
* Handle paths with an id section (#ref)
* Make sure url encoding is working
* Make sure path encoding is working
* Handle references without a uri
* Make sure updating non-uri refs does not leave orphan cited papers
* Validate JSON
* Validate that internal references (references in a group) are valid
* Make sure that invalid content and accept types return errors
* Handle JSON parser failures on post/put (This is in the middleware stack)
* Provide CORS support
* Optimize caching support If-Modified-Since/etag+If-None-Match
* Add a 'plugin' system to allow processors (for ex NLM to JSON)
* Do NLM to JSON conversion
* Audit Logging: Add details of changes (diff)
* Extract URI validator into a validation class
* Web/Test interface
* Add routing tests
* Add ?pretty=true option

Future/Low Priority
=====================
* Handle JSON Patch format
* Rate limiting

Open Questions
===============
* How should we structure get requests to include/extend extened metadata?
* API Versioning
* Should we restructure the JSON
* How should we handle multiple writes
* What format should we use for Uri's of citations without a URI?
* How do we report JSON errors
* Should we disable changing the 'ref' value of a citation?
  If we allow it there could/will be inconsistencies with cross-references from the citation groups data
