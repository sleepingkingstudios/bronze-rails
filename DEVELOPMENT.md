# Development

- Responders
  - extract error key mapping to Responders::Errors.
  - JsonResponder: builds a JSON api response

## Future Work

- I18nService
  - Handles locale-based fallback (en-gb, en)
  - Handles returned hash objects (e.g. when querying a sub-key).
- ResourcesController support for associations
  - Boss belongs to Dungeon, has one Enforcer, has many Minions
