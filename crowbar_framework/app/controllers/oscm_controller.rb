class OscmController < BarclampController
  # Controller for Oscm barclamp

  protected

  def initialize_service
    @service_object = OscmService.new logger
  end
end