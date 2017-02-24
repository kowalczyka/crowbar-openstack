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

    if nodes.size >= 1
      base["deployment"]["oscm"]["elements"] = {
        "oscm-server" => [ nodes.first[:fqdn] ]
      }
    end
    
    @logger.debug("Oscm create_proposal: exiting")
    base
  end

  def validate_proposal_after_save(proposal)
    validate_one_for_role proposal, "oscm-server"

    super
  end

  def apply_role_pre_chef_call(_old_role, role, all_nodes)
    @logger.debug("Oscm apply_role_pre_chef_call: "\
                  "entering #{all_nodes.inspect}")

    @logger.debug("Oscm apply_role_pre_chef_call: leaving")
  end
end
