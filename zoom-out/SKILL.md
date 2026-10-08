---
name: zoom-out
description: Re-pitch the current work in prose at Product Owner level, from the bigger picture down to user behavior before vs after and the high-level flow of the change. Use when the user says "zoom out", "zoom-out", "wait what?", wants the bigger picture, a functional PO view of what the user sees, or signals they are lost or have no idea what this is about.
---

Wait, I don't understand where you've got to here... Re-pitch that: give me a little bit of context.

Part of the problem is that I don't know this area of code well, so go up a layer of abstraction and explain it from there. Answer in prose, in your own words: no maps, mermaid, or diagrams, and no template of headings or bullets to fill in.

Start by talking me through it freely, from where we are back to the bigger picture: what this part of the product is for, how the piece we are touching fits in, and why it matters. Stay at the level a Product Owner sees. Use domain words, not code words, and leave out classes, files, or APIs unless they are the product surface. If a fact is missing, say so instead of inventing a rule.

By the end, in whatever order reads best, the prose should have made clear what the user could do before and what failed, was missing, or was promised but not delivered; what the user can do after the change, its success path, and what must never happen; the high-level flow of the change, from what triggers it through its steps to the outcome; and what behavior stays the same. Weave in the product decisions already taken that constrain the behavior, only the explicit ones, and the watchouts the product must not forget, such as edge cases, tenant differences, promises to the user, or known gaps, without implementation notes.

If there is no change behind my confusion, only a concept or an area I don't understand, drop the before, the after, and the flow of the change, and explain how it works today instead. Never invent a change to fill that space.