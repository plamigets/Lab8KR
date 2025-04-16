defmodule Book do
  @filename "bookPrint.txt"

  defstruct iban: "", title: "", author: "", publication_date: ""

  def start do
    loop()
  end

  defp loop do
    IO.puts("\nSelect an option:")
    IO.puts("1. Enter new book")
    IO.puts("2. Delete book")
    IO.puts("3. Show existing books")
    IO.puts("4. Update book")
    IO.puts("5. Exit")

    input = IO.gets("> ") |> String.trim()

    case input do
      "1" ->
        IO.puts("-------------------------------------------")
        add_book()
        loop()

      "2" ->
        IO.puts("-------------------------------------------")
        delete_book()
        loop()

      "3" ->
        IO.puts("-------------------------------------------")
        show_books()
        loop()

      "4" ->
        IO.puts("-------------------------------------------")
        update_book()
        loop()

      "5" ->
        IO.puts("Exit... Byyeeee!")

      _ ->
        IO.puts("Invalid option.")
        loop()
    end
  end

  defp read_file do
    if not File.exists?(@filename) do
      File.write!(@filename, "")
    end

    case File.read(@filename) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          [iban, title, author, publication_date] = String.split(line, ",")
          %Book{
            iban: iban,
            title: title,
            author: author,
            publication_date: publication_date
          }
        end)

      {:error, _} -> []
    end
  end

  defp write_file(books) do
    content =
      Enum.map(books, fn %Book{iban: i, title: t, author: a, publication_date: p} ->
        "#{i},#{t},#{a},#{p}"
      end)
      |> Enum.join("\n")

    File.write!(@filename, content)
  end

  defp add_book do
    IO.puts("Enter iban:")
    iban = IO.gets("> ") |> String.trim()

    IO.puts("Enter title:")
    title = IO.gets("> ") |> String.trim()

    IO.puts("Enter author:")
    author = IO.gets("> ") |> String.trim()

    IO.puts("Enter publication date:")
    publication_date = IO.gets("> ") |> String.trim()

    books = read_file()

    case Enum.find(books, fn b -> b.iban == iban end) do
      nil ->
        new_book = %Book{iban: iban, title: title, author: author, publication_date: publication_date}
        write_file([new_book | books])
        IO.puts("Book added.")

      _ ->
        IO.puts("A book with this iban already exists!")
    end
  end

  defp delete_book do
    IO.puts("Enter iban to delete:")
    iban = IO.gets("> ") |> String.trim()

    books = read_file()
    new_books = Enum.reject(books, fn b -> b.iban == iban end)

    if length(new_books) < length(books) do
      write_file(new_books)
      IO.puts("The book is deleted.")
    else
      IO.puts("No book found with the given iban.")
    end
  end

  defp show_books do
    books = read_file()

    if Enum.empty?(books) do
      IO.puts("No books found.")
    else
      Enum.each(books, fn b ->
        IO.puts(
          "IBAN: #{b.iban}, Title: #{b.title}, Author: #{b.author}, Publication Date: #{b.publication_date}"
        )
      end)
    end
  end


  defp update_book do
    IO.puts("Enter iban to update:")
    iban = IO.gets("> ") |> String.trim()

    books = read_file()

    case Enum.find(books, fn b -> b.iban == iban end) do
      nil ->
        IO.puts("Book is not found.")

      old_book ->
        IO.puts("Enter new title (current: #{old_book.title}):")
        title = IO.gets("> ") |> String.trim()

        IO.puts("Enter new author (current: #{old_book.author}):")
        author = IO.gets("> ") |> String.trim()

        IO.puts("Enter new publication year (current: #{old_book.publication_date}):")
        publication_date = IO.gets("> ") |> String.trim()

        updated = %Book{iban: iban, title: title, author: author, publication_date: publication_date}

        new_list =
          Enum.map(books, fn b ->
            if b.iban == iban, do: updated, else: b
          end)

        write_file(new_list)
        IO.puts("Book is updated.")
    end
  end

end

Book.start()
