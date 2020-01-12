defmodule Health.Data.BloodPressures do
  @moduledoc """
  The Data.BloodPressures context.
  """

  import Ecto.Query, warn: false
  alias Health.Repo

  alias Health.Data.BloodPressures.Pressure
  alias Health.Accounts.User

  @doc """
  Returns the list of pressures.

  ## Examples

      iex> list_pressures()
      [%Pressure{}, ...]

  """
  def list_pressures do
    Repo.all(Pressure)
  end

  def list_user_pressures(user) do
    Pressure
    |> where([p], p.user_id == ^user.id)
    |> Repo.all()
  end

  def list_user_pressures(current_page, per_page, %User{} = user)
      when is_integer(current_page) and is_integer(per_page) do
    Pressure
    |> where([p], p.user_id == ^user.id)
    |> order_by([p], desc: p.time)
    |> offset([], ^((current_page - 1) * per_page))
    |> limit([], ^per_page)
    |> Repo.all()
  end

  def list_user_pressures(start_date, end_date, %User{} = user) do
    Pressure
    |> where([p], p.user_id == ^user.id)
    |> where([p], p.time >= ^start_date)
    |> where([p], p.time <= ^end_date)
    |> order_by([p], desc: p.time)
    |> Repo.all()
  end

  @doc """
  Gets a single pressure.

  Raises `Ecto.NoResultsError` if the Pressure does not exist.

  ## Examples

      iex> get_pressure!(123)
      %Pressure{}

      iex> get_pressure!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pressure!(id), do: Repo.get!(Pressure, id)

  @doc """
  Creates a pressure.

  ## Examples

      iex> create_pressure(%{field: value})
      {:ok, %Pressure{}}

      iex> create_pressure(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pressure(attrs \\ %{}) do
    %Pressure{}
    |> Pressure.changeset(attrs)
    |> Repo.insert()
  end

  def create_pressure(%User{} = user, attrs) do
    %Pressure{}
    |> Pressure.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a pressure.

  ## Examples

      iex> update_pressure(pressure, %{field: new_value})
      {:ok, %Pressure{}}

      iex> update_pressure(pressure, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pressure(%Pressure{} = pressure, attrs) do
    pressure
    |> Pressure.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Pressure.

  ## Examples

      iex> delete_pressure(pressure)
      {:ok, %Pressure{}}

      iex> delete_pressure(pressure)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pressure(%Pressure{} = pressure) do
    Repo.delete(pressure)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pressure changes.

  ## Examples

      iex> change_pressure(pressure)
      %Ecto.Changeset{source: %Pressure{}}

  """
  def change_pressure(%Pressure{} = pressure) do
    Pressure.changeset(pressure, %{})
  end
end
