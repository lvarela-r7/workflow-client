#This class takes in a ticket and replaces predefined tokens with
#the actual data that will be posted to the ticketing system
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
        next if value.kind_of? Symbol

        if key == :body or key == :headers
          tokenized_ticket[key].each do |k,v|
            p tokenized_ticket[key][k].inspect if v.index(token_key)
            tokenized_ticket[key][k].gsub!(token_key, ticket_data[token_value] || '') if v.index(token_key)
          end
        else
          tokenized_ticket[key].gsub!(token_key, ticket_data[token_value] || '') if value.index(token_key)
        end
      end
    end

    tokenized_ticket
  end

  private
  def build_default_tokens
    tokens = {}

    tokens["$NODE_ADDRESS$"] = :ip
    tokens["$NODE_NAME$"] = :name
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
