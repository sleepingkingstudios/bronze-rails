# Development

- Responders
  - extract error key mapping to Responders::Errors.
  - JsonResponder: builds a JSON api response
- Add specs for Rails 5.1
- Move shared Rails file copying to CI step.

## Future Work

- I18nService
  - Handles locale-based fallback (en-gb, en)
  - Handles returned hash objects (e.g. when querying a sub-key).
- ResourcesController support for associations
  - Boss belongs to Dungeon, has one Enforcer, has many Minions
