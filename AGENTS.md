## Technical

- written in Ruby
- Tests with RSpec, execute `rspec` to run them
- Code-Style is checked with RuboCop, run `rubocop` to check

## Ideas

The project is a CLI that collects time-tracking information into entries and allows to show them.
The data-backend is either the data of gtimelog or of a dialy note in Obsidian.md

### gtimelog

gtimelog is a GTK GUI app, that uses a single file to store when a task has ended.

This allows to infer the duration of tasks by reading mulitple lines.

### Obsidian.md

Obsidian.md (mostly called obsidian) is a note-taking application allows to have daily notes in markdown-format.

The plugin 'dayplanner' adds a special section to daily notes that are time-tracking entries. They are grouped under a headline and formatted like this

```markdown
- 10:00 - 11:00 Task 17: Hard work, Analysis, Feedback -- work client mail
```

This describes a time-entry from 10:00 to 11:00 o'clock. The entry's ticket is "Task 17" and its description is "Hard work, Analysis, Feedback". The entry is tagged with "work", "client" and "mail"

## Development-Workflow

- Always write a spec first
- The spec should define the desired state
- The spec should be failing at first
- Then add the implementation
- The spec should now be successful
- The whole spec-suite should also still be without errors
- run `rspec` to ensure that
- if any spec fails, fix the new implementation until all specs pass
- Lastly, run `rubocop` to ensure the code-style is good.
- verify completeness by running `rspec` and `rubocop`.
- Propose a commit-message, summarizing the need for the change
