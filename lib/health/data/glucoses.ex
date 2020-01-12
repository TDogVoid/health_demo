defmodule Health.Data.Glucoses do
  @moduledoc """
  The Data context.
  """

  import Ecto.Query, warn: false
  alias Health.Repo

  alias Health.Data.Glucoses.Glucose
  alias Health.Accounts.User

  @doc """
  Returns the list of glucoses.

  ## Examples

      iex> list_glucoses(%User{})
      [%Glucose{}, ...]

  """
  def list_user_glucoses(%User{} = user) do
    Glucose
    |> where([g], g.user_id == ^user.id)
    |> order_by([g], desc: g.time)
    |> Repo.all()
    |> Repo.preload(:period)
  end

  def list_user_glucoses(current_page, per_page, %User{} = user)
      when is_integer(current_page) and is_integer(per_page) do
    Glucose
    |> where([g], g.user_id == ^user.id)
    |> order_by([g], desc: g.time)
    |> offset([], ^((current_page - 1) * per_page))
    |> limit([], ^per_page)
    |> Repo.all()
    |> Repo.preload(:period)
  end

  def list_user_glucoses(start_date, end_date, %User{} = user) do
    Glucose
    |> where([g], g.user_id == ^user.id)
    |> where([g], g.time >= ^start_date)
    |> where([g], g.time <= ^end_date)
    |> order_by([g], desc: g.time)
    |> Repo.all()
    |> Repo.preload(:period)
  end

  @doc """
  Gets a single glucose.

  Raises `Ecto.NoResultsError` if the Glucose does not exist.

  ## Examples

      iex> get_glucose!(123)
      %Glucose{}

      iex> get_glucose!(456)
      ** (Ecto.NoResultsError)

  """
  def get_glucose!(id) do
    Glucose
    |> Repo.get!(id)
    |> Repo.preload(:period)
  end

  @doc """
  Creates a glucose.

  ## Examples

      iex> create_glucose(%{field: value})
      {:ok, %Glucose{}}

      iex> create_glucose(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_glucose(attrs \\ %{}) do
    %Glucose{}
    |> Glucose.changeset(attrs)
    |> Repo.insert()
  end

  def create_glucose(%User{} = user, attrs) do
    %Glucose{}
    |> Glucose.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a glucose.

  ## Examples

      iex> update_glucose(glucose, %{field: new_value})
      {:ok, %Glucose{}}

      iex> update_glucose(glucose, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_glucose(%Glucose{} = glucose, attrs) do
    glucose
    |> Glucose.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Glucose.

  ## Examples

      iex> delete_glucose(glucose)
      {:ok, %Glucose{}}

      iex> delete_glucose(glucose)
      {:error, %Ecto.Changeset{}}

  """
  def delete_glucose(%Glucose{} = glucose) do
    Repo.delete(glucose)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking glucose changes.

  ## Examples

      iex> change_glucose(glucose)
      %Ecto.Changeset{source: %Glucose{}}

  """
  def change_glucose(%Glucose{} = glucose) do
    Glucose.changeset(glucose, %{})
  end
end
