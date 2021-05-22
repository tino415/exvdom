defmodule ExvdomTest do
  use ExUnit.Case
  doctest Exvdom

  import Exvdom

  describe "render/1" do
    test "sample 1" do
      expected = Enum.join([
        "<html>",
        "<header>",
        "<title>Example</title>",
        "</header>",
        "<body>",
        "<div><div>Hello world</div></div>",
        "</body>",
        "</html>"
      ])

      assert expected == render(sample1())
    end

    test "sample 2" do
      expected = Enum.join([
        "<html>",
        "<header>",
        "<title>Example</title>",
        "</header>",
        "<body>",
        "<div><div>Hello world 2 &lt; %</div><div>added</div></div>",
        "</body>",
        "</html>"
      ])

      assert expected == render(sample2())
    end
  end

  describe "diff/2" do
    test "not changed" do
      assert %{} == diff(sample1(), sample1())
    end

    test "changed" do
      assert %{
        [1, 0, 0, 0] => {:update, "Hello world 2 &lt; %"},
        [1, 0, 0, :class] => "mutte",
        [1, 0, 1] => {:append, "<div>added</div>"}
      } == diff(sample1(), sample2())
    end
  end


  def sample1 do
    html([], [
      header([], [
        title("Example")
      ]),
      body([], [
        div_([class: "container"], [
          div_([], [text "Hello world"])
        ])
      ])
    ])
  end

  def sample2 do
    html([], [
      header([], [
        title("Example")
      ]),
      body([], [
        div_([class: "container"], [
          div_([class: "mutte"], [text "Hello world 2 < %"]),
          div_([], [text "added"])
        ])
      ])
    ])
  end
end
