DSpace Services Addon
======

This application is a set of webservice addons for DSpace. Some are broadly useful, but others are only really applicable to the UN's particular repository implementation. 

Presently there are two main endpoints:

## DSpace Object Embedder ##

This endpoint is an oEmbed service provider for DSpace repositories. It does a number of things.

1. Provides handle-based metadata simplification (so far, just for individual items) for use as an iframe source. For instance, http://service.url/dsoembed/embed/handle/12345/999 will output a simplified HTML representation of the DSpace object that lives at the specified handle.
2. Generates embed code (iframe) to allow the contents of a DSpace handle to be embedded on external websites. The oEmbed API endpoint in this code is at http://service.url/dsoembed Note that url is a required parameter, so a minimally complete oEmbed call looks like http://service.url/dsoembed?url=http://google.com Further note that, since this is a project for use in the United Nations, there are some hard-coded UN-specific things in here. These should not be hard to change if you want to use this code for your own purposes, but right now making it more universal is not my priority.

What it doesn't do (yet):

1. Provide XML responses via the oEmbed API. It's JSON only. I have no interest in changing this.
2. Account for all of the potential error conditions it can encounter. Namely, it's missing responses for suggesting when something isn't implemented, and it could use better handling for 404 and 401 errors of which there are none and one, respectively.
3. Allow additional parameters through the not-yet-implemented client-side builder. The endpoint provides some options, but not everything I foresee needing. Specifying metadata field inclusion would be a good start.
4. Allow embedding of communities, collections, and search results. These are coming soon.

## Document Symbol Resolver/Redirector ##

These endpoints take a UN document symbol, such as S/2010/10, and resolves it to a DSpace URL. As such, they are very simple.

The endpoint at /services/symbol performs a redirect to a DSpace URL, either directly to an item whose document symbol matches exactly the given symbol, or to a search page with the given symbol as the search term in cases where there was no exact match. This allows partial symbol resolution in cases where someone wants to build an externally hosted form against this as an API. It is anticipated that the most frequent use case will be to scan an existing text for document symbols, which can then be translated into an interstitial non-canonical URL, e.g., S/2010/10 in our case translates into a link to http://dag.un.org/services/symbol/S/2010/10 This, when finally deployed, is nothing more than a redirection to http://dag.un.org/handle/11176/13548 It should be noted that one can, if desired, use the CNRI Handle issued for the item: http://hdl.handle.net/11176/13548 which is itself a proxy and will redirect. 

The endpoint at /services/resolve will take the document symbol as an argument and return a JSON document containing the repository URL for the resouce. The anticipated use case here is to populate data sets without propagating proxy links, if that is a concern. Perhaps the point is more for reference than for API development.

## How to install this ##

You can do this a couple of ways. 

### Tomcat (what I'm using) ###

Clone the repo. Make sure you have Ruby, Bundler and Warble install. I am using JRuby for this, but I don't know if it's required.

`bundle install`

`warble war`

Copy the resulting .war file to your Tomcat webapps directory. Your endpoints will be available at ${dspace.url}/services/oembed, ${dspace.url}/services/embed, ${dspace.url}/services/symbol, and ${dspace.url}/services/resolve

### Rackup ###

Clone the repo. Make sure you have Ruby and Bundler installed. 

`bundle install`

`rackup`

Access it on port 9292. Your endpoints are at /services/oembed, /services/embed, /services/symbol and /services/resolve
