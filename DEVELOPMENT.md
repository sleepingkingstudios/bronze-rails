# Development

- I18nService
  - Handles key-based fallback (specific to general)
- ResourcefulResponseBuilder
  - implement messages
    - "Successfully actioned resource"
    - "Unable to action resource"
    - defaults to
      I18n.t('resources.:resource_name.:action_name.:status', :locale => locale)
    - falls back to I18n.t('resources.:action_name.:status', :resource => resource_name, :locale => locale)
  - support API responses
- ResourcesController
  - ::resource :only, :except, :api, :views - filter actions
    - make excluded actions private?
  - #operation_builder - support different types of operations
    - ActiveRecordOperationBuilder?
- Responders
  - RenderViewResponder: pass messages to flash
  - JsonResponder: builds a JSON api response

## Future Work

- I18nService
  - Handles locale-based fallback (en-gb, en)
- ResourcesController support for associations
  - Boss belongs to Dungeon, has one Enforcer, has many Minions
