<div align="center">

# Neorg Roadmap

</div>

Given the rapid growth and adoption of Neorg it's critical that a development plan is
established to not only help the development team keep track of progress but to also
facilitate and encourage contributions from the flourishing community.

This file is written and maintained in Markdown for easy viewing on GitHub.
It will be switched to a `.norg` file when possible.

# Neorg

## Miscellaneous

- [ ] Make `core.clipboard.code-blocks` work with a visual selection.
- [x] Reimplement the `core.maneouvre` module, which has been deprecated since `1.0`.
- [ ] The `a` and `b` commands in the hop module are not implemented.
- [ ] Readd colouring to TODO items.

## Workflow

- [x] [The Calendar UI](#calendar)
- [ ] The GTD Methodology
- [ ] Zettelkasten
- [ ] The `sc-im`esque Table Editor

To achieve the above, a set of cross-platform tools must be initially developed.
For the motivation behind this, see the [external tools](#external-tooling) section.

## Documentation

- [ ] Develop and ship a Neorg landing page with documentation, presumably with docasaurus.
    - [x] Provide a written tutorial on how to get started with Neorg.
    - [ ] Provided a tutorial on how to develop for Neorg (modules, events, etc.).
- [ ] Provide a dropdown in the wiki which will display a module's entire configuration as a lua snippet.

### Calendar

The calendar is a planned sophisticated and flexible tool for selecting a date.
While it sounds rather trivial, the calendar is the main user interaction for any
date related operation. Because of this, there are many components to a calendar.

At its core the calendar is simply supposed to allow the user to select a date.
This is such a vast concept however that the calendar should be able to handle a variety
of situations/contexts.

#### Context Switching

Depending on the preferred context, the calendar should be able to work in four
major views - `DAILY`, `WEEKLY`, `MONTHLY` and `YEARLY`. Each mode has a
different layout fit for the task at hand, and displays varying amounts of
information based on said view.

- The daily view displays only the current day, but allows you to quickly select an hour in that day.
  Moving left or right moves one hour forward or backward, respectively.
  The view is vertical, meaning an hour takes up a horizontal bar and they are stacked top to bottom starting
  from midnight.
- The weekly view displays all 7 days of the week. Moving forwards or backwards moves one day forward
  or backward, respectively. This view is also vertical, where each day takes up a single bar
  of the view.
- The monthly view shows all days of the month in a horizontally rendered fashion.
  It is the default mode if none is specified.
- The yearly view is meant to summarize more than it is supposed to serve any function.
  The details of this view have not yet been fully drawn out.

As with all things Neorg, other modules should be free to create their own
views via an API. Apart from just creating views, any module should be free to
add "custom data" to the view, which the view should be able to handle
appropriately through a set of default API functions. An example of this may be
the GTD module, which could display all the tasks for a day in the daily view, or
it could highlight a day as red in the monthly view if there are urgent tasks
that have not been yet completed.

#### Keybinds

The user experience comes first - the keybinds should be as close as possible to vim, with
slight deviations if the keybinds hinder the "mnemonic" keybind model, where a sequence of words
(e.g. `delete around word`) can be converted to a set of keybinds (`daw`).

# Cross-Compatibility

Walled gardens? No thanks. Conversion from (and to) `.norg` and Neorg workflows should be
hassle-free.

- [ ] [Pandoc](https://pandoc.org/) integration. A pandoc parser (or lua filter) would be super
      useful to convert to and from the `.norg` file format. Work has begun (but is currently stalled)
      in the following [PR](https://github.com/nvim-neorg/neorg/pull/684). There is also an incomplete
      pandoc parser written in Haskell [here](https://github.com/Simre1/neorg-haskell-parser), so if you
      have some Haskell skills then this is your time to help out! :)
- [ ] Inbuilt upgraders from `.org` to `.norg`, and vice versa.
      Org and markdown are the most common formats to convert to `.norg`, and whereas markdown can
      be handled just fine by pandoc, org may need some extra fine tuning to work effectively. We'd
      like for Neorg to be able to "understand" workflows within emacs's `org-mode`, such as the
      inbuilt agenda view and others, and convert them into the Neorg-appropriate counterpart.

# External Tooling

External tooling is a great way to help Neorg see adoption in spaces other than Neovim. While the
best features will remain within the Neorg plugin for Neovim, writing tools for `.norg` and for
Neorg should not be difficult nor discouraging. As a result, we'll create and maintain a set of
embeddable-anywhere tools. These include:

- [ ] Parsers in several languages - the first step of supporting Neorg is supporting its underlying
  file format, `.norg`. Because Norg is a well-standardized format, many parsers can be created
  for it without forming annoying "dialects". Currently, the most well supported parser is the
  `tree-sitter` parser, which is embeddable essentially anywhere thanks to its library being written
  in C.
  Apart from [`tree-sitter`](https://github.com/nvim-neorg/tree-sitter-norg), work-in-progress
  parsers can be found for many languages like [`rust`](https://github.com/max397574/rust-norg),
  [`zig`](https://github.com/vhyrro/zig-norg),
  [`haskell`](https://github.com/Simre1/neorg-haskell-parser) and
  [`julia`](https://github.com/klafyvel/Norg.jl)!
- [x] Directory Manager and File Aggregator - workspaces are a pretty fundamental concept within
  Neorg, and writing a tool that can efficiently manage and manipulate enormous collections
  of notes will be critical for any Neorg-like tool.
- [x] Multithreaded parsing library - note collections can get big, like really big. Parsing
      all of these on a single thread could take even minutes. Having a good multithreaded
      parsing library will help a lot.
- [x] Norgopolis and its related modules - norgopolis servers as a router for all server side
      logic, including the database, for the multithreaded Treesitter parser, as well as for
      managing active workspaces. Many clients may connect to this server, establishing a single
      source of truth for any `n` amount of clients.
- [x] SurrealDB - Neorg's preferred backend for execution is SurrealDB, a modern multi-model
      database. It was specifically chosen because, apart from just being able to store data in a relational
      format (like sqlite), it also has the ability of creating and operating on nodes like a graph database.
      This allows for lighting fast lookups of e.g. links, tasks and/or inline metadata in the file.
- [ ] GTD - this library would form the backend for the "Getting Things Done" methodology.
      It would do all the heavy lifting, including managing notes, contexts and a bit more.
      Afterwards all it takes is to write a frontend (the UI) in the application of your choice to
      fully support Neorg's GTD capabilities.
- [ ] Zettelkasten - similarly to GTD, the backend for zettelkasten will be implemented as a
      library. This library would primarily handle backlinks, which are painfully slow to track natively
      in Lua, which runs on a single thread.


A logistics question - how do these libraries play with Neorg in Neovim itself?
All of the libaries we mentioned will be written in Rust, and via `cbindgen` we will
generate `.o`/`.so` library files that may be used anywhere, including Neovim.
Lua has great support for importing shared library objects, so all that it takes
is a Github action that compiles e.g. the `GTD` backend library, pulling in all dependencies,
packing it into a small `.so`, and then shipping it directly with Neorg!

# Mobile Application

A mobile tool for Neorg would greatly increase it's adoption range thanks to portability. Such a
mobile application could utilize all of the [external tools](#external-tooling) written by us
to ensure that it's consistent in behaviour with all of the other Neorg tools in the ecosystem.

Features of a mobile application would include:
- [ ] A synchronisation mechanism between the mobile device and any other end devices.
- [ ] A fast note capturing mechanism - if you have a random idea while e.g. going on a walk,
      writing it down should only be two clicks away.
      This note capturing mechanism should ideally be powered by the [GTD](#external-tooling)
      library.
- [ ] A pleasant UX - phone screens are fairly small, so UI fluidness and the way notes/tasks
      are displayed should be as effective as possible.

# Artificial Intelligence

Do not worry, we're not a new startup overhyping AI thinking it will change the world. Also don't fret, we
will not use AI like most companies as a tactic to collect and send information to servers for data
analysis.

We strongly believe that for a specific and specialized subset of tasks artificial intelligence (or,
more specifically, natural language processing tools) are a novel way to aid in note taking. All
models shipped by Neorg would not be in the main Neorg package, but as addon plugins. These addon
plugins would ship with the model placed locally on your machine, and no contact with an external
server would be required to use these models.

There are currently only three use cases that we would like to use natural language processing for, and these are:
- [ ] Speech to text recognition for the [mobile application](#mobile-application).
- [ ] Automatic detection of contexts for a given GTD task. This takes away the manual process of having to
      assign contexts for each of your tasks.
- [ ] Zettelkasten sorters - because an NLP model has a good understanding of loosely similar
      information and topics, it could be much more effective at categorizing, reordering and linking
      zettels than a traditional programmatic algorithm.

All of these plans are for the very far future, long after [GTD and Zettelkasten](#workflow) are complete. However,
if you have experience in training such models or would like to help, then do not hesitate!
