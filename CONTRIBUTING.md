# Contributing rules
1- Each phase in the project must have a branch that all changes should be committed on. ex. (Master -> Proof_of_concept)

2- Branch names should be *preferably* one word or multiple words joined by an underscore. ex. (Proof_of_concept)

3- Developing a feature begins with checking out a new branch from a phase branch. ex. (Master -> Proof_of_concept -> new_node_detection)

4- After finishing a feature, its branch is merged to the phase branch then deleted 

5- Commit messages must be descriptive

6- Commit messages must be prefixed by one of these tags:

| Tag | Description |
| --- | ----------- |
| [Fix] | For a bug fix or feature re-implementation |
| [Doc] | For adding documentation of any type (file, image or in-code documentation) |
| [Feature] | When creating or continuing working on a feature |
| [Clean] | For removing unwanted files or segments of code |
| [Merge] | For merging a branch |
| [Revert] | For reverting a commit (typically when using ``git revert #{commit code}``) |
| [Misc] | For any other reason unlisted here |
