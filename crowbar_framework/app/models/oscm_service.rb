class OscmService < PacemakerServiceObject
  def initialize(thelogger)
    @bc_name = "oscm"
    @logger = thelogger
  end

  class << self
    # Turn off multi proposal support till it really works and people ask for it.
    def self.allow_multiple_proposals?
      false
    end

    def role_constraints
      {
        "oscm-server" => {
          "unique" => false,
          "count" => 1,
          "admin" => true,
        },
      }
    end
  end

  def create_proposal
    @logger.debug("Oscm create_proposal: entering")
    base = super

    nodes = NodeObject.all
	
	server_nodes = nodes.select { |n| n.intended_role == "controller" }
    server_nodes = [nodes.first] if server_nodes.empty?

    base["deployment"]["oscm"]["elements"] = {
      "oscm-server" => [server_nodes.first.name]
    } unless server_nodes.nil?
    
    @logger.debug("Oscm create_proposal: exiting")
    base
  end

  def validate_proposal_after_save(proposal)
    validate_one_for_role proposal, "oscm-server"

    super
  end

end
