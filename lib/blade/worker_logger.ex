defmodule Blade.WorkerLogger do
  require Logger

  def handle_event([:oban, :job, :start], measure, meta, _) do
    Logger.info("[Oban] :started #{meta.worker} at #{measure.system_time}")
  end

  def handle_event([:oban, :job, event], measure, meta, _) do
    Logger.info("[Oban] #{event} #{meta.worker} ran in #{measure.duration}")
  end
end
