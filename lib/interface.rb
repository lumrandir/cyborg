# encoding: utf-8

require 'pp'

module Interface
  class CyWindow < Gtk::Window
    def initialize app
      @app = app
      @crypt_mode = :mono
      @key = String.new
      @source = String.new
      super "Cyborg Window"
      
      set_title "Cyborg"
      set_default_size 400, 300
      set_border_width 10

      # text_views
      source_view = Gtk::TextView.new
      source_view.set_border_width 10
      encrypted_view = Gtk::TextView.new
      encrypted_view.set_border_width 10
      decrypted_view = Gtk::TextView.new
      decrypted_view.set_border_width 10

      views_box = Gtk::HBox.new
      views_box.pack_start source_view, true, true, 0
      views_box.pack_start encrypted_view, true, true, 0
      views_box.pack_start decrypted_view, true, true, 0

      #control buttons
      process_button = Gtk::Button.new "Шифровать"
      open_button = Gtk::Button.new "Открыть файл..."
      close_button = Gtk::Button.new "Выйти"

      buttons_box = Gtk::VBox.new
      buttons_box.pack_start process_button, false, false, 0
      buttons_box.pack_start open_button, false, false, 0
      buttons_box.pack_start close_button, false, false, 0

      #key generation
      key_entry = Gtk::Entry.new
      gen_key_button = Gtk::Button.new "Генерировать"

      key_box = Gtk::HBox.new
      key_box.pack_start key_entry, false, false, 0
      key_box.pack_start gen_key_button, false, true, 0

      #mode selection
      radio1 = Gtk::RadioButton.new "_Одноалфавитная подстановка"
      radio2 = Gtk::RadioButton.new radio1, "_Многоалфавитная подстановка"
      radio3 = Gtk::RadioButton.new radio1, "_Перестановка"
      radio4 = Gtk::RadioButton.new radio1, "_Решётка Кардано"
      mode_box = Gtk::VBox.new
      mode_box.pack_start radio1, false, false, 0
      mode_box.pack_start radio2, false, false, 0
      mode_box.pack_start radio3, false, false, 0
      mode_box.pack_start radio4, false, false, 0

      #mode and buttons
      bottom_box = Gtk::HBox.new
      bottom_box.pack_start mode_box, true, true, 0
      bottom_box.pack_start buttons_box, true, true, 0

      #main form
      box = Gtk::VBox.new
      box.pack_start views_box, true, true, 0
      box.pack_start key_box, false, true, 0
      box.pack_start bottom_box, true, true, 0

      add box

      signal_connect("delete_event") {
        Gtk.main_quit
      }

      close_button.signal_connect("clicked") {
        Gtk.main_quit
      }

      open_button.signal_connect("clicked") {
        browse_dialog = Gtk::FileChooserDialog.new(
          "Выберите текст", self, Gtk::FileChooser::ACTION_OPEN, nil,
          [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
          [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT]
        )
        if browse_dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
          buffer = Gtk::TextBuffer.new
          tmp = String.new
          File.open(browse_dialog.filename, 'r') { |f|
            while line = f.gets
              tmp << line
            end
          }
          buffer.text = tmp
          source_view.buffer = buffer
        end
        browse_dialog.destroy
      }
      
      gen_key_button.signal_connect("clicked") {
        key_entry.text = @app.generate_key source_view.buffer.text.force_encoding("utf-8").size
      }

      process_button.signal_connect("clicked") {
        if radio1.active?
          encrypted_view.buffer.text, decrypted_view.buffer.text = @app.monoalphabetic(
            source_view.buffer.text.force_encoding("utf-8"), key_entry.text.to_i
          )
        elsif radio2.active?
          encrypted_view.buffer.text, decrypted_view.buffer.text = @app.polyalphabetic(
            source_view.buffer.text.force_encoding("utf-8"), key_entry.text.force_encoding("utf-8")
          )
        elsif radio3.active?
          encrypted_view.buffer.text, decrypted_view.buffer.text = @app.permutation(
            source_view.buffer.text.force_encoding("utf-8"), key_entry.text.force_encoding("utf-8")
          )
        elsif radio4.active?
          encrypted_view.buffer.text, decrypted_view.buffer.text = @app.cardano(
            source_view.buffer.text.force_encoding("utf-8")
          )
        end
      }

      self.show_all
      Gtk.main
    end
  end
end
