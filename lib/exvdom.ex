defmodule Exvdom do
  def tag(name, attributes \\ [], content \\ []) do
    {:tag, name, Map.new(attributes), content}
  end

  def text(value) do
    {:text, HtmlEntities.encode(value)}
  end

  def html(attributes \\ [], content \\ []) do
    tag(:html, attributes, content)
  end

  def header(attributes \\ [], content \\ []) do
    tag(:header, attributes, content)
  end

  def body(attributes \\ [], content \\ []) do
    tag(:body, attributes, content)
  end

  def title(content) do
    tag(:title, [], [text content])
  end

  def div_(attributes \\ [], content \\ []) do
    tag(:div, attributes, content)
  end

  def diff(tag1, tag2) do
    diff([], %{}, tag1, tag2)
  end

  def diff(_path, changes, same, same) do
    changes
  end

  def diff(path, changes, {:tag, name, old_attributes, old}, {:tag, name, new_attributes, new}) do
    {old, new} = zip_pad(old, new)

    changes =
      Map.keys(old_attributes) ++ Map.keys(new_attributes)
      |> Enum.uniq()
      |> Enum.reduce(changes, fn key, changes ->
        old = Map.get(old_attributes, key)
        new = Map.get(new_attributes, key)

        if old == new do
          changes
        else
          Map.put(changes, path ++ [key], new)
        end
      end)

    Enum.zip(old, new)
    |> Enum.with_index()
    |> Enum.reduce(changes, fn {{old, new}, index}, changes ->
      diff(path ++ [index], changes, old, new)
    end)
  end

  def diff(path, changes, _old, nil) do
    Map.put(changes, path, nil)
  end

  def diff(path, changes, nil, new) do
    Map.put(changes, path, {:append, render(new)})
  end

  def diff(path, changes, _old, new) do
    Map.put(changes, path, {:update, render(new)})
  end

  def render({:text, value}) do
    value
  end

  def render({:tag, name, %{}, content}) do
    name = render_name(name)
    "<#{Atom.to_string(name)}>#{render_content(content)}</#{name}>"
  end

  def render({:tag, name, attributes, content}) do
    name = render_name(name)
    "<#{Atom.to_string(name)} #{render_attributes(attributes)}>#{render_content(content)}</#{name}>"
  end

  defp render_name(name) do
    name
  end

  defp render_attributes(attributes) do
    attributes
    |> Enum.map(&render_attribute(&1))
    |> Enum.join(" ")
  end

  defp render_content(children) do
    children
    |> Enum.map(&render(&1))
    |> Enum.join("")
  end

  defp render_attribute({name, value}) do
    ~s(#{Atom.to_string(name)}="#{HtmlEntities.encode(value)}")
  end

  defp zip_pad(enum1, enum2) when length(enum1) < length(enum2) do
    {pad_to(enum1, length(enum2)), enum2}
  end

  defp zip_pad(enum1, enum2) when length(enum2) < length(enum1) do
    {enum1, pad_to(enum2, length(enum1))}
  end

  defp zip_pad(enum1, enum2), do: {enum1, enum2}

  defp pad_to(enum, len) do
    pad = Enum.map(length(enum)..len, fn _ -> nil end)
    enum ++ pad
  end
end
