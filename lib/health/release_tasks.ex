defmodule Health.ReleaseTasks do

  def eval_purge_stale_data() do
    # Eval commands needs to start the app before
    # Or Application.load(:my_app) if you can't start it
    Application.ensure_all_started(:health)
    Application.ensure_all_started(:timex)
  end

  def create_user(args) do
    Application.ensure_all_started(:timex)
    Application.ensure_all_started(:tzdata)
    Application.load(:health)
    Health.Accounts.create_user(args)
  end
    
end
