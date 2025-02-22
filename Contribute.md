# Contribute

This Document holds some basic Information and Rules,
which people have to follow for Contributing.
It solely focusses on the technical Rules and Processes

## Git Ops

There are a lot of different ways to interact with git, from no schema at all, over to **Git-Flow**. <br>
For This Project we are doing **Trunk Based Development**. <br>
We are using this schema, so we have minimal overhead from git, while still
receiving some of the advantages of a more advanced Branching schema like:

- consistent naming
- easier merges thanks to short living branches

while not having **Release Hell** which is quite common with **Git-Flow**.

There are a lot of different definitions of **Trunk Based Development** and **Semantic Versioning**,
so to ensure everybody is on the same foot, we are writing down our definitions.

---

### Trunk Based Development

In **Trunk Based Development**, there is a main branch called the **trunk** (or main/master) in which
all Features are merged into.
Developers don't commit directly into the trunk, but into short lived **Feature Branches** which are merged with **PRs**.  <br>
Releases are marked on the trunk with the usage of **Git Tags** for this most often **Semantic Versioning** is used.

#### Feature Branches

Feature Branches for us follow into one of three categories:

- **Feature** - A new Feature
- **Bugfix** - A Bugfix
- **Chore** - A Chore like updating the Readme

> [!NOTE]
> Some Project also employ more specific branch types like:
>
> - **Hotfix** - A Bugfix which has to be done fast (most often right after a release)
> - **Story** - An Agile User story based Branch
> - **Tasks** - A Subtask of a story
>
> but **these are not used by us**.

##### Branch Naming

Branches should be named with a prefix of their type like:
`feature/{description}`

The Descriptie part of the branch should describe what this is about,
in the [Slug](https://en.wikipedia.org/wiki/Clean_URL#Slug) format for readabillity.

If you are not sure how to "slugify" a description,
you can use tools like [this](https://blog.tersmitten.nl/slugify/).

###### Example Names

Branch for a Bugfix where a Player can walk throug walls:
`bugfix/player-wall-collisions`

Branch for implementing a system for NPCs
`feature/npc-system`

Branch for updating some links in the Credits of the Game and the Readme
`chore/update-credit-links`

---

### Semantic Versioning

In Semantic Versioning, there are 3 Parts to the Version Number:

**MAJOR**.**MINOR**.**PATCH**

These parts are Incremented depending on what changed between versions

#### Major

As soon as External APIs or in our case Game Saves break, it is seen as a Major change

#### Minor

If only new Features are added and there are no breakages and changes to existing ones,
it is a Minor change.

#### Patch

If the changes between versions only fix Bugs and CVEs, it is seen as a Patch version.

---

### Commits

Commit Messages should be descriptive. 
For CVE Patching and otehr kind of Bugs, the Commit history should be clean, meaning that
unclean history like:
- WIP: Fix try 1
- FIx try 2
- Fixing it Fr this time

should be squashed into:
- Fix: Player Collisions
