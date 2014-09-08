{models} = require 'feeds'

class Aggregator extends models.Aggregator
  deserialize: JSON.parse

  render: ({id, data, timestamp}) =>
    # The id is of form /:provider/:model/:id
    [_, provider, model, id] = id.split '/'
    {provider, model, id, data, timestamp}

module.exports = {Aggregator}
