defmodule Rewizard.Cogs.FindAll do
  @behaviour Nosedrum.Command

  alias Nostrum.Api
  import Nostrum.Struct.Embed
  alias Rewizard.Embeds

  @impl true
  def usage, do: ["find_all <regex> <target>", "find_all <regex> <flags> <target>"]

  @impl true
  def description, do: "Find all this regex matches in that target"

  @impl true
  def predicates, do: [&Rewizard.Predicates.correct_channel/1, &Rewizard.Predicates.rate_limit/1]

  def success(regex, target, result) do
    Embeds.success("Find All")
    |> Embeds.regex(regex)
    |> put_field("Target", "`#{target}`")
    |> put_field("Result", "`#{inspect(result)}`")
  end

  def failed(tpl_regex, message) do
    Embeds.fail("Find All")
    |> Embeds.regex(tpl_regex)
    |> put_field("Error", message)
  end

  def find(str_regex, flags, target) do
    res =
      with {:ok, regex} <- Rewizard.Regex.compile(str_regex, flags),
           {:ok, result} <- Rewizard.Regex.find_all(regex, target),
           do: success(regex, target, result)

    case res do
      {:error, str_regex, msg} ->
        failed(str_regex, msg)

      {:fail, regex, msg} ->
        failed(Rewizard.Regex.source(regex), msg)

      _ ->
        res
    end
  end

  @impl true
  def command(msg, [str_regex, target]) do
    reply = find(str_regex, "", target)
    Api.create_message!(msg.channel_id, embed: reply)
  end

  @impl true
  def command(msg, [str_regex, flags, target]) do
    reply = find(str_regex, flags, target)
    Api.create_message!(msg.channel_id, embed: reply)
  end
end
