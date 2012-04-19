class Tokenizer

  def initialize
    @tokens = build_default_tokens
  end

  def tokenize(ticket_data={}, ticket={}, custom_tokens={})
    tokenized_ticket = {}

    @tokens.merge! custom_tokens if custom_tokens

    ticket.each do |key, value|
      tokenized_ticket[key] = value

      @tokens.each do |token_key, token_value|
        tokenized_ticket[key].gsub!(token_key, ticket_data[token_value]) if value.index(token_key)
      end
    end

    tokenized_ticket
  end

  private
  def build_default_tokens
    tokens = {}

    tokens["$NODE_ADDRESS$"] = :node_address
    tokens["$NODE_NAME$"] = :node_name
    tokens["$VENDOR$"] = :vendor
    tokens["$PRODUCT$"] = :product
    tokens["$FAMILY$"] = :family
    tokens["$VERSION$"] = :version
    tokens["$VULN_STATUS$"] = :vuln_status
    tokens["$VULN_ID$"] = :vuln_id
    tokens["$VULN_TITLE$"] = :vuln_title
    tokens["$DESC$"] = :description
    tokens["$PROOF$"] = :proof
    tokens["$SOLUTION$"] = :solution
    tokens["$SCAN_START$"] = :scan_start
    tokens["$SCAN_END$"] = :scan_end
    tokens["$CVSS_SCORE$"] = :cvss_score

    tokens
  end
end
