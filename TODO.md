Todos
==============
* Add transaction to POST/PUT
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
* Validate that internal references (references in a group) are valid
* Make sure that invalid content and accept types return errors
* Handle JSON parser failures on post/put (This is in the middleware stack)
* Provide CORS support
* Optimize caching support If-Modified-Since/etag+If-None-Match
* Add a 'plugin' system to allow processors (for ex NLM to JSON)
* Do NLM to JSON conversion
* Audit Logging: Add details of changes (diff)
* Web/Test interface
* Add ?pretty=true option

Future/Low Priority
=====================
* Handle JSON Patch format
* Rate limiting

Open Questions
===============
* How should we structure get requests to include/extend extened metadata?
* API Versioning
* How should we handle multiple writes
* How do we report JSON errors
* Should we disable changing the 'ref' value of a citation?
  If we allow it there could/will be inconsistencies with cross-references from the citation groups data
