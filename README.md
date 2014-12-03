dsoembed
======

DSpace Object Embedder

There is no guarantee I will understand what I am doing here, but, here's what I plan to accomplish:

1.  Embed anything available from the DSpace REST interface into an external website with a simple URL call, e.g., http://localhost:4567/embed?url=http%3A%2F%2F54.172.204.197%2Frest%2Fcollections%2F7%3Fexpand%3Dall as the source of an iframe.
2.  Select metadata for display in the embed.
3.  Provide a lookup that translates DSpace handles into object IDs in the local repository. I consider this nontrivial.
4.  Package nicely in a way that facilitates inclusion in a Tomcat type web application. Documentation on how to do this seems plentiful, so I don't consider this difficult. Ask me again after I try to do it, though.

I originally wanted to make this look like oEmbed, and I may still do that. It's not a priority at the moment, however.
