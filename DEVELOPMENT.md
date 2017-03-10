# Development

- support for nested resources with :association_name
  - integration specs: Dragon#lair => Dungeon
    - Grendel the Green, Ambrose the Amber, Charles the Chartreuse
    - Prideparadinoth the Polychromatic
- ResourcefulResponseBuilder
  - implement messages
    - "Successfully actioned resource"
    - "Unable to action resource"
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

- ResourcesController support for associations
  - Boss belongs to Dungeon, has one Enforcer, has many Minions
