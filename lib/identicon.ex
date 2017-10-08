defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
    Accepts an `input` (string) and returns an image
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
    Accepts an `image` (image file) and an `filename` (string) and saves the image
    to the hard drive with the name as the `filename`
  """
  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end

  @doc """
    Accepts an `Identicon.Image` struct with a color and pixel map and
    returns a grid image where the pixel map points are filled with the
    image's color
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
    Accepts an `image` (`Identicon.Image` struct) and returns an `Identicon.Image`
    struct with a pixel map that contains 50x50 px grid points that should
    be filled with a color in the grid
  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    Accepts an `image` (`Identicon.Image` struct) and returns an `Identicon.Image`
    struct with an updated grid that only includes hex numbers that are even
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Accepts an `image` (`Identicon.Image` struct) and returns an `Identicon.Image`
    struct with a grid property that is a list of its hex values as
    {value, index} tuples
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Accepts a `row` (list) and returns a list that mirrors the
    first two things of the list and appends them to the end of the list

  ## Example
    iex> Identicon.mirror_row([1,2,3])
    [1,2,3,2,1]
  """
  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  @doc """
    Accepts an `image` (`Identicon.Image` struct) and returns an `Identicon.Image`
    struct with the RGB value for the color

  ## Example
      iex> Identicon.pick_color(%Identicon.Image{hex: [145, 46, 200, 3, 178, 200, 73, 228, 165, 65, 6, 141, 73, 90, 181, 112]})
      %Identicon.Image{color: {145, 46, 200},
       hex: [145, 46, 200, 3, 178, 200, 73, 228, 165, 65, 6, 141, 73, 90, 181, 112]}
  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
    Accepts an `input` (string) and returns an `Identicon.Image` struct with a
    hex that's an MD5 hash

  ## Example
      iex> Identicon.hash_input("asdf")
      %Identicon.Image{color: nil,
       hex: [145, 46, 200, 3, 178, 206, 73, 228, 165, 65, 6, 141, 73, 90, 181, 112]}
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
