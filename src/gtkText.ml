(* $Id$ *)

open Gaux
open Gobject
open Gtk
open Tags
open GtkProps
open GtkBase

external _gtktext_init : unit -> unit = "ml_gtktext_init"
let () = _gtktext_init ()

(* This function helps one to guess the type of the arguments of signals *)
let marshal_what f _ = function 
  | `OBJECT _ :: _  -> invalid_arg "OBJECT"
  | `BOOL _ ::_ -> invalid_arg "BOOL"  
  | `CHAR _::_ -> invalid_arg "CHAR"
  | `FLOAT _::_ -> invalid_arg "FLOAT"
  | `INT _::_ -> invalid_arg "INT"
  | `INT64 _::_ -> invalid_arg "INT64"
  | `NONE::_ -> invalid_arg "NONE"
  | `POINTER _::_ -> invalid_arg "POINTER"
  | `STRING _::_  -> invalid_arg "STRING"
  | [] -> invalid_arg "NO ARGUMENTS"


let text_iter_of_pointer = ref (fun _ -> failwith "text_iter_of_pointer")

module Mark = struct
  let cast w : text_mark = Object.try_cast w "GtkTextMark"
  exception No_such_mark of string
  external set_visible : text_mark -> bool -> unit 
    = "ml_gtk_text_mark_set_visible"
  external get_visible : text_mark -> bool = "ml_gtk_text_mark_get_visible"
  external get_deleted : text_mark -> bool = "ml_gtk_text_mark_get_deleted"
  external get_name : text_mark -> string option = "ml_gtk_text_mark_get_name"
  external get_buffer : text_mark -> text_buffer option
    = "ml_gtk_text_mark_get_buffer"
  external get_left_gravity : text_mark -> bool 
    = "ml_gtk_text_mark_get_left_gravity"
end

module Tag = struct
  include TextTag
  external create : string -> text_tag = "ml_gtk_text_tag_new"
  external get_priority : text_tag -> int = "ml_gtk_text_tag_get_priority"
  external set_priority : text_tag -> int -> unit 
    = "ml_gtk_text_tag_set_priority"
  external event : text_tag -> 'a obj ->  'b Gdk.event -> text_iter -> bool
    = "ml_gtk_text_tag_event"
  module Signals = struct
    open GtkSignal
    let marshal_event f _ = function
      |`OBJECT(Some p)::`POINTER(Some ev)::`POINTER(Some ti)::_ ->
	 f ~origin:p 
	  (GdkEvent.unsafe_copy ev : GdkEvent.any)
	  (!text_iter_of_pointer ti)
      | _ -> invalid_arg "GtkText.Tag.Signals.marshal_event"
	  
    let event = 
      {
	name = "event";
	classe = `texttag;
	marshaller = marshal_event
      }
  end
end

module TagTable = struct
  let cast w : text_tag_table = Object.try_cast w "GtkTextTagTable"
  external create : unit -> text_tag_table = "ml_gtk_text_tag_table_new"
  external add : text_tag_table -> text_tag -> unit = "ml_gtk_text_tag_table_add"
  external remove : text_tag_table -> text_tag -> unit = "ml_gtk_text_tag_table_remove"
  external lookup : text_tag_table -> string -> text_tag option 
    = "ml_gtk_text_tag_table_lookup"
  external get_size : text_tag_table -> int = "ml_gtk_text_tag_table_get_size"
  module Signals = struct
  open GtkSignal

  let marshal_text_tag f _ = function 
    |`OBJECT(Some p)::_ ->
       f (Gobject.unsafe_cast p : text_tag)
    | _ -> invalid_arg "GtkText.Buffer.Signals.marshal_text_tag"

  let marshal_tag_changed f _ = function 
    | `OBJECT(Some p)::`BOOL b::_ ->
       f (Gobject.unsafe_cast p : text_tag) b
    | _ -> invalid_arg "GtkText.Buffer.Signals.marshal_tag_changed"

  let tag_added = 
      {
	name = "tag-added";
	classe = `texttagtable;
	marshaller = marshal_text_tag
      }
  let tag_changed = 
      {
	name = "tag-changed";
	classe = `texttagtable;
	marshaller = marshal_tag_changed
      }
  let tag_removed = 
      {
	name = "tag-removed";
	classe = `texttagtable;
	marshaller = marshal_text_tag
      }
  end
end

module Buffer = struct
  open Gpointer
  let cast w : text_buffer = Object.try_cast w "GtkTextBuffer"
  external create : text_tag_table option 
    -> text_buffer = "ml_gtk_text_buffer_new"
  external get_line_count : text_buffer -> int 
    = "ml_gtk_text_buffer_get_line_count"
  external get_char_count : text_buffer -> int 
    = "ml_gtk_text_buffer_get_char_count"
  external get_tag_table : text_buffer -> text_tag_table 
    = "ml_gtk_text_buffer_get_tag_table"
  external insert : text_buffer -> text_iter -> string stable -> unit
    = "ml_gtk_text_buffer_insert"
  let insert a b c = insert a b (stable_copy c)
  external insert_at_cursor : text_buffer -> string stable -> unit
    = "ml_gtk_text_buffer_insert_at_cursor"
  let insert_at_cursor a b = insert_at_cursor a (stable_copy b)
  external insert_interactive :
    text_buffer -> text_iter -> string stable -> bool -> bool
    = "ml_gtk_text_buffer_insert_interactive"
  let insert_interactive a b c = insert_interactive a b (stable_copy c)
  external insert_interactive_at_cursor :
    text_buffer -> string stable -> bool -> bool
    = "ml_gtk_text_buffer_insert_interactive_at_cursor"
  let insert_interactive_at_cursor a b =
    insert_interactive_at_cursor a (stable_copy b)
  external insert_range : text_buffer -> text_iter -> text_iter
    -> text_iter -> unit = "ml_gtk_text_buffer_insert_range"
  external insert_range_interactive : text_buffer -> text_iter -> text_iter
    -> text_iter -> bool -> bool = "ml_gtk_text_buffer_insert_range_interactive"
  external delete : text_buffer -> text_iter -> text_iter -> unit
    = "ml_gtk_text_buffer_delete"
  external delete_interactive : text_buffer -> text_iter -> text_iter 
    -> bool -> bool = "ml_gtk_text_buffer_delete_interactive"
  external set_text : text_buffer -> string stable -> unit
    = "ml_gtk_text_buffer_set_text"
  let set_text b s = set_text b (stable_copy s)
  external get_text : text_buffer -> text_iter -> text_iter -> 
    bool -> string = "ml_gtk_text_buffer_get_text"
  external get_slice : text_buffer -> text_iter -> text_iter -> 
    bool -> string = "ml_gtk_text_buffer_get_slice"
  external insert_pixbuf : text_buffer -> text_iter -> GdkPixbuf.pixbuf
    -> unit = "ml_gtk_text_buffer_insert_pixbuf"
  external create_mark : text_buffer -> string option -> text_iter
    -> bool -> text_mark = "ml_gtk_text_buffer_create_mark"
  external move_mark : text_buffer -> text_mark -> text_iter
   -> unit  = "ml_gtk_text_buffer_move_mark"
  external move_mark_by_name : text_buffer -> string -> text_iter
   -> unit  = "ml_gtk_text_buffer_move_mark_by_name"
  external delete_mark : text_buffer -> text_mark 
    -> unit  = "ml_gtk_text_buffer_delete_mark"
  external delete_mark_by_name : text_buffer -> string
   -> unit  = "ml_gtk_text_buffer_delete_mark_by_name"
  external get_mark : text_buffer -> string -> text_mark option 
    = "ml_gtk_text_buffer_get_mark"
  external get_insert : text_buffer -> text_mark 
    = "ml_gtk_text_buffer_get_insert"
  external get_selection_bound : text_buffer -> text_mark 
    = "ml_gtk_text_buffer_get_selection_bound"
  external place_cursor : text_buffer -> text_iter -> unit 
    = "ml_gtk_text_buffer_place_cursor"
  external apply_tag : text_buffer -> text_tag -> text_iter -> text_iter 
    -> unit = "ml_gtk_text_buffer_apply_tag"
  external remove_tag : text_buffer -> text_tag -> text_iter -> text_iter 
    -> unit = "ml_gtk_text_buffer_remove_tag"
  external apply_tag_by_name : text_buffer -> string -> text_iter -> text_iter 
    -> unit = "ml_gtk_text_buffer_apply_tag_by_name"
  external remove_tag_by_name : text_buffer -> string -> text_iter -> text_iter 
    -> unit = "ml_gtk_text_buffer_remove_tag_by_name"
  external remove_all_tags : text_buffer -> text_iter -> text_iter 
    -> unit = "ml_gtk_text_buffer_remove_all_tags"
  external create_tag_0 : text_buffer -> string option 
    -> text_tag = "ml_gtk_text_buffer_create_tag_0"
  external create_tag_2 : text_buffer -> string option 
    -> string -> string -> text_tag = "ml_gtk_text_buffer_create_tag_2"
  external get_iter_at_line_offset : text_buffer -> int -> int -> text_iter
    = "ml_gtk_text_buffer_get_iter_at_line_offset"
  external get_iter_at_offset : text_buffer -> int -> text_iter
    = "ml_gtk_text_buffer_get_iter_at_offset"
  external get_iter_at_line : text_buffer ->  int -> text_iter
    = "ml_gtk_text_buffer_get_iter_at_line"
  external get_iter_at_line_index : text_buffer ->  int -> int -> text_iter
    = "ml_gtk_text_buffer_get_iter_at_line_index"
  external get_iter_at_mark : text_buffer -> text_mark -> text_iter
    = "ml_gtk_text_buffer_get_iter_at_mark"
  external get_start_iter : text_buffer 
    -> text_iter = "ml_gtk_text_buffer_get_start_iter"
  external get_end_iter : text_buffer 
    -> text_iter = "ml_gtk_text_buffer_get_end_iter"
  external get_bounds : text_buffer -> text_iter * text_iter
    = "ml_gtk_text_buffer_get_bounds"
  external get_modified : text_buffer -> bool
    = "ml_gtk_text_buffer_get_modified"
  external set_modified : text_buffer -> bool -> unit
    = "ml_gtk_text_buffer_set_modified"
  external delete_selection : text_buffer ->  bool -> bool -> bool
    = "ml_gtk_text_buffer_delete_selection"
  external get_selection_bounds : text_buffer ->  text_iter * text_iter
    = "ml_gtk_text_buffer_get_selection_bounds"
  external begin_user_action : text_buffer -> unit
    = "ml_gtk_text_buffer_begin_user_action"
  external end_user_action : text_buffer -> unit
    = "ml_gtk_text_buffer_end_user_action"
  external create_child_anchor : text_buffer 
    -> text_iter -> text_child_anchor
    = "ml_gtk_text_buffer_create_child_anchor"
  external insert_child_anchor : 
    text_buffer -> text_iter -> text_child_anchor -> unit
    = "ml_gtk_text_buffer_insert_child_anchor"
  external paste_clipboard :
    text_buffer -> clipboard -> text_iter option -> bool -> unit
    = "ml_gtk_text_buffer_paste_clipboard"
  external copy_clipboard :
    text_buffer -> clipboard -> unit
    = "ml_gtk_text_buffer_copy_clipboard"
  external cut_clipboard :
    text_buffer -> clipboard -> bool -> unit
    = "ml_gtk_text_buffer_cut_clipboard"
  external add_selection_clipboard :
    text_buffer -> clipboard -> unit
    = "ml_gtk_text_buffer_add_selection_clipboard"
  external remove_selection_clipboard :
    text_buffer -> clipboard -> unit
    = "ml_gtk_text_buffer_remove_selection_clipboard"
  module Signals = struct
  open GtkSignal

  let marshal_apply_tag f _ = function 
    |`OBJECT(Some p)::`POINTER(Some ti1)::`POINTER(Some ti2)::_ ->
       f (Gobject.unsafe_cast p : text_tag)
        ~start:(!text_iter_of_pointer ti1) 
	~stop:(!text_iter_of_pointer ti2)
    | _ -> invalid_arg "GtkText.Buffer.Signals.marshal_apply_tag"

  let marshal_delete_range f _ = function 
    | `POINTER(Some ti1)::`POINTER(Some ti2)::_ ->
       f ~start:(!text_iter_of_pointer ti1) 
	~stop:(!text_iter_of_pointer ti2)
    | _ -> invalid_arg "GtkText.Buffer.Signals.marshal_delete_range"
  let marshal_insert_child_anchor f _ = function 
    | `POINTER(Some ti)::`OBJECT(Some tca)::_ ->
       f (!text_iter_of_pointer ti) 
	(Gobject.unsafe_cast tca : text_child_anchor)
    | _ -> invalid_arg "GtkText.Buffer.Signals.marshal_insert_child_anchor"


  let marshal_insert_pixbuf f _ = function 
    | `POINTER(Some ti)::`OBJECT(Some pb)::_ ->
       f (!text_iter_of_pointer ti) (Gobject.unsafe_cast pb : GdkPixbuf.pixbuf)
    | _ -> invalid_arg "GtkText.Buffer.Signals.marshal_insert_pixbuf"

  let marshal_insert_text f argv = function 
    | `POINTER(Some ti)::`STRING(Some s)::`INT len::_  ->
(*        let s' =
          if len = -1 then (prerr_endline "HERE -1";s) else
            (prerr_endline "HERE NOW";
	     Gpointer.peek_string ~pos:0 ~len
               (Gobject.Closure.get_pointer argv ~pos:2))
        in
*)
	f (!text_iter_of_pointer ti) s
    | _ -> invalid_arg "GtkText.Buffer.Signals.marshal_insert_text"
	
  let marshal_text_mark f _ = function 
    | `OBJECT(Some tm)::_ -> 
	f (Gobject.unsafe_cast tm : text_mark)
    | _ -> invalid_arg "GtkText.Buffer.Signals.marshal_text_mark"

  let marshal_mark_set f _ = function 
    | `POINTER(Some ti)::`OBJECT(Some tm)::_ -> 
	f (!text_iter_of_pointer ti) (Gobject.unsafe_cast tm : text_mark) 
    | _ -> invalid_arg "GtkText.Buffer.Signals.marshal_mark_set"
  
  let marshal_remove_tag f _ = function 
    |`OBJECT(Some p)::`POINTER(Some ti1)::`POINTER(Some ti2)::_ ->
       f (Gobject.unsafe_cast p : text_tag) 
	~start:(!text_iter_of_pointer ti1) 
	~stop:(!text_iter_of_pointer ti2)
    | _ -> invalid_arg "GtkText.Buffer.Signals.marshal_remove_tag"

  let apply_tag = 
      {
	name = "apply_tag";
	classe = `textbuffer;
	marshaller = marshal_apply_tag
      }
    let begin_user_action = 
      { name = "begin_user_action"; 
	classe = `textbuffer;
	marshaller = marshal_unit }
    let changed = 
      { name = "changed"; 
	classe = `textbuffer;
	marshaller = marshal_unit }
    let delete_range =
      { name = "delete-range";
	classe = `textbuffer;
	marshaller = marshal_delete_range }
    let end_user_action = 
      { name = "end_user_action"; 
	classe = `textbuffer;
	marshaller = marshal_unit }
    let insert_child_anchor =
      { name = "insert-child-anchor";
	classe = `textbuffer;
	marshaller = marshal_insert_child_anchor}
    let insert_pixbuf =
      {name = "insert-pixbuf";
       classe = `textbuffer;
       marshaller = marshal_insert_pixbuf
      }
    let insert_text =
      {name = "insert-text";
       classe = `textbuffer;
       marshaller = marshal_insert_text
      }
    let mark_deleted =
      {name = "mark-deleted";
       classe = `textbuffer;
       marshaller = marshal_text_mark
      }
    let mark_set = 
      {name = "mark-set";
       classe = `textbuffer;
       marshaller = marshal_mark_set
      }
    let modified_changed = 
      { name = "modified-changed"; 
	classe = `textbuffer;
	marshaller = marshal_unit }
    let remove_tag = 
      { name = "remove-tag"; 
	classe = `textbuffer;
	marshaller = marshal_remove_tag }
end    
end

module ChildAnchor = struct
  let cast w : text_child_anchor = Object.try_cast w "GtkTextChildAnchor"
  external create : unit -> text_child_anchor =
	"ml_gtk_text_child_anchor_new"
  external get_widgets : text_child_anchor -> widget obj list =
	"ml_gtk_text_child_anchor_get_widgets"
  external get_deleted : text_child_anchor -> bool =
	"ml_gtk_text_child_anchor_get_deleted"
end

module View = struct
  include TextView
  external create_with_buffer : text_buffer -> text_view obj = "ml_gtk_text_view_new_with_buffer"
  external set_buffer : [>`textview] obj -> text_buffer -> unit = "ml_gtk_text_view_set_buffer"
  external get_buffer : [>`textview] obj -> text_buffer = "ml_gtk_text_view_get_buffer"
  external scroll_to_mark : [>`textview] obj -> text_mark -> float -> bool -> float -> float -> unit = 
	    "ml_gtk_text_view_scroll_to_mark_bc" "ml_gtk_text_view_scroll_to_mark"
  external scroll_to_iter : [>`textview] obj -> text_iter -> float -> bool -> float -> float -> bool = 
	    "ml_gtk_text_view_scroll_to_iter_bc" "ml_gtk_text_view_scroll_to_iter"
  external scroll_mark_onscreen : [>`textview] obj -> text_mark -> unit = 
	   "ml_gtk_text_view_scroll_mark_onscreen"
  external move_mark_onscreen : [>`textview] obj -> text_mark -> bool = 
	   "ml_gtk_text_view_move_mark_onscreen"
  external place_cursor_onscreen : [>`textview] obj -> bool = 
	   "ml_gtk_text_view_place_cursor_onscreen"
  external get_visible_rect : [>`textview] obj -> Gdk.Rectangle.t = 
	   "ml_gtk_text_view_get_visible_rect"
  external get_iter_location : [>`textview] obj -> text_iter -> Gdk.Rectangle.t = 
	   "ml_gtk_text_view_get_iter_location"
  external get_line_at_y : [>`textview] obj -> int -> text_iter*int = 
	   "ml_gtk_text_view_get_line_at_y"
  external get_line_yrange : [>`textview] obj -> text_iter -> int*int = 
	   "ml_gtk_text_view_get_line_yrange"
  external get_iter_at_location : [>`textview] obj -> int -> int -> text_iter = 
	   "ml_gtk_text_view_get_iter_at_location"
  external buffer_to_window_coords : [>`textview] obj -> Gtk.Tags.text_window_type -> int -> int -> int*int =
	   "ml_gtk_text_view_buffer_to_window_coords"
  external window_to_buffer_coords : [>`textview] obj -> Gtk.Tags.text_window_type -> int -> int -> int*int =
	   "ml_gtk_text_view_window_to_buffer_coords"
  external get_window : [>`textview] obj -> Gtk.Tags.text_window_type -> Gdk.window option =
	   "ml_gtk_text_view_get_window"
  external get_window_type : [>`textview] obj -> Gdk.window -> Gtk.Tags.text_window_type =
	   "ml_gtk_text_view_get_window_type"
  external set_border_window_size : [>`textview] obj -> [`LEFT | `RIGHT | `TOP | `BOTTOM ] -> int -> unit =
	   "ml_gtk_text_view_set_border_window_size"
  external get_border_window_size : [>`textview] obj ->  [`LEFT | `RIGHT | `TOP | `BOTTOM ] -> int =
	   "ml_gtk_text_view_get_border_window_size"
  external forward_display_line : [>`textview] obj -> text_iter -> bool =
	   "ml_gtk_text_view_forward_display_line"
  external backward_display_line : [>`textview] obj -> text_iter -> bool =
	   "ml_gtk_text_view_backward_display_line"
  external forward_display_line_end : [>`textview] obj -> text_iter -> bool =
	   "ml_gtk_text_view_forward_display_line_end"
  external backward_display_line_start : [>`textview] obj -> text_iter -> bool =
	   "ml_gtk_text_view_backward_display_line_start"
  external starts_display_line : [>`textview] obj -> text_iter -> bool =
	   "ml_gtk_text_view_starts_display_line"
  external move_visually : [>`textview] obj -> text_iter -> int -> bool =
	   "ml_gtk_text_view_move_visually"
  external add_child_at_anchor : 
    [>`textview] obj -> [>`widget] obj -> text_child_anchor -> unit =
	   "ml_gtk_text_view_add_child_at_anchor"
  external add_child_in_window : 
    [>`textview] obj -> [>`widget] obj -> text_window_type -> int -> int -> unit =
	   "ml_gtk_text_view_add_child_in_window"
  external move_child : 
    [>`textview] obj -> [>`widget] obj -> int -> int -> unit =
	   "ml_gtk_text_view_move_child"

  module Signals = struct
    open GtkSignal

    let marshal_delete_from_cursor f _ = function 
      |`INT ty ::`INT i ::_ ->
	 f (Gpointer.decode_variant GtkEnums.delete_type ty) i
      | _ -> invalid_arg "GtkText.View.Signals.marshal_delete_from_cursor"
    let marshal_move_cursor f _ = function 
      |`INT step :: `INT i :: `BOOL b :: _ ->
	 f (Gpointer.decode_variant GtkEnums.movement_step step) i b
      | _ -> invalid_arg "GtkText.View.Signals.marshal_move_cursor"
    let marshal_move_focus f _ = function 
      |`INT dir :: _ ->
	 f (Gpointer.decode_variant GtkEnums.direction_type dir)
      | _ -> invalid_arg "GtkText.View.Signals.marshal_move_focus"
    let marshal_page_horizontally f _ = function 
      | (`INT i)::(`BOOL b)::_ ->
	 f i b
      | _ -> invalid_arg "GtkText.View.Signals.marshal_page_horizontally"
    let marshal_populate_popup f _ = function 
      |`OBJECT(Some p)::_ ->
	 f (Gobject.unsafe_cast p : menu obj) 
      | _ -> invalid_arg "GtkText.View.Signals.marshal_populate_popup"
    
    let marshal_set_scroll_adjustments f _ = function 
      |`OBJECT(Some p1)::`OBJECT(Some p2)::_ ->
	  f (Gobject.unsafe_cast p1 : adjustment obj)
            (Gobject.unsafe_cast p2 : adjustment obj) 
      | _ -> invalid_arg "GtkText.View.Signals.marshal_set_scroll_adjustments"


    let copy_clipboard = 
      {
	name = "copy-clipboard";
	classe = `textview;
	marshaller = marshal_unit
      }
    let cut_clipboard = 
      {
	name = "cut-clipboard";
	classe = `textview;
	marshaller = marshal_unit
      }
    let delete_from_cursor = 
      {
	name = "delete-from-cursor";
	classe = `textview;
	marshaller = marshal_delete_from_cursor
      }
    let insert_at_cursor = 
      {
	name = "insert-at-cursor";
	classe = `textview;
	marshaller = marshal_string
      }
    let move_cursor = 
      {
	name = "move-cursor";
	classe = `textview;
	marshaller = marshal_move_cursor
      }
    let move_focus = 
      {
	name = "move-focus";
	classe = `textview;
	marshaller = marshal_move_focus
      }
    let page_horizontally = 
      {
	name = "page-horizontally";
	classe = `textview;
	marshaller = marshal_page_horizontally
      }
    let paste_clipboard = 
      {
	name = "paste-clipboard";
	classe = `textview;
	marshaller = marshal_unit
      }
    let populate_popup = 
      {
	name = "populate-popup";
	classe = `textview;
	marshaller = marshal_populate_popup
      }
    let set_anchor = 
      {
	name = "set-anchor";
	classe = `textview;
	marshaller = marshal_unit
      }
    let set_scroll_adjustments = 
      {
	name = "set-scroll-adjustments";
	classe = `textview;
	marshaller = marshal_set_scroll_adjustments
      }
    let toggle_overwrite = 
      {
	name = "toggle-overwrite";
	classe = `textview;
	marshaller = marshal_unit
      }
  end
end

module Iter = struct
  external copy : text_iter -> text_iter = "ml_gtk_text_iter_copy"
  let () =
    text_iter_of_pointer := (fun (p : Gpointer.boxed) -> copy (Obj.magic p))
  external get_buffer : text_iter -> text_buffer = "ml_gtk_text_iter_get_buffer"
  external get_offset : text_iter -> int = "ml_gtk_text_iter_get_offset"
  external get_line : text_iter -> int = "ml_gtk_text_iter_get_line"
  external get_line_offset : text_iter -> int = "ml_gtk_text_iter_get_line_offset"
  external get_line_index : text_iter -> int = "ml_gtk_text_iter_get_line_index"
  external get_visible_line_index : text_iter -> int = "ml_gtk_text_iter_get_visible_line_index"
  external get_visible_line_offset : text_iter -> int = "ml_gtk_text_iter_get_visible_line_offset"
  external get_char : text_iter -> Glib.unichar = "ml_gtk_text_iter_get_char"
  external get_slice : text_iter -> text_iter -> string = "ml_gtk_text_iter_get_slice"
  external get_text : text_iter -> text_iter -> string = "ml_gtk_text_iter_get_text"
  external get_visible_slice : text_iter -> text_iter -> string = 
	   "ml_gtk_text_iter_get_visible_slice"
  external get_visible_text : text_iter -> text_iter -> string = "ml_gtk_text_iter_get_visible_text"
  external get_pixbuf : text_iter -> GdkPixbuf.pixbuf option = "ml_gtk_text_iter_get_pixbuf"
  external get_marks : text_iter -> text_mark list = "ml_gtk_text_iter_get_marks"
  external get_toggled_tags : text_iter -> bool -> text_tag list = "ml_gtk_text_iter_get_toggled_tags"
  external get_child_anchor : text_iter -> text_child_anchor option ="ml_gtk_text_iter_get_child_anchor"
  external begins_tag : text_iter -> text_tag option -> bool = "ml_gtk_text_iter_begins_tag"
  external ends_tag : text_iter -> text_tag option -> bool = "ml_gtk_text_iter_ends_tag"
  external toggles_tag : text_iter -> text_tag option -> bool = "ml_gtk_text_iter_toggles_tag"
  external has_tag : text_iter -> text_tag -> bool = "ml_gtk_text_iter_has_tag"
  external get_tags : text_iter -> text_tag list = "ml_gtk_text_iter_get_tags"
  external editable : text_iter -> default:bool -> bool = "ml_gtk_text_iter_editable"
  external can_insert : text_iter -> default:bool -> bool = "ml_gtk_text_iter_can_insert"
  external starts_word : text_iter -> bool = "ml_gtk_text_iter_starts_word"
  external ends_word : text_iter -> bool = "ml_gtk_text_iter_ends_word"
  external inside_word : text_iter -> bool = "ml_gtk_text_iter_inside_word"
  external starts_line : text_iter -> bool = "ml_gtk_text_iter_starts_line"
  external ends_line : text_iter -> bool = "ml_gtk_text_iter_ends_line"
  external starts_sentence : text_iter -> bool = "ml_gtk_text_iter_starts_sentence"
  external ends_sentence : text_iter -> bool = "ml_gtk_text_iter_ends_sentence"
  external inside_sentence : text_iter -> bool = "ml_gtk_text_iter_inside_sentence"
  external is_cursor_position : text_iter -> bool = "ml_gtk_text_iter_is_cursor_position"
  external get_chars_in_line : text_iter -> int = "ml_gtk_text_iter_get_chars_in_line"
  external get_bytes_in_line : text_iter -> int = "ml_gtk_text_iter_get_bytes_in_line"
  external get_language : text_iter -> Pango.language = 
   "ml_gtk_text_iter_get_language"
  external is_end : text_iter -> bool = "ml_gtk_text_iter_is_end"
  external is_start : text_iter -> bool = "ml_gtk_text_iter_is_start"
  external forward_char : text_iter -> bool = "ml_gtk_text_iter_forward_char"
  external backward_char : text_iter -> bool = "ml_gtk_text_iter_backward_char"
  external forward_chars : text_iter -> int -> bool = "ml_gtk_text_iter_forward_chars"
  external backward_chars : text_iter -> int -> bool = "ml_gtk_text_iter_backward_chars"
  external forward_line : text_iter -> bool = "ml_gtk_text_iter_forward_line"
  external backward_line : text_iter -> bool = "ml_gtk_text_iter_backward_line"
  external forward_lines : text_iter -> int -> bool = "ml_gtk_text_iter_forward_lines"
  external backward_lines : text_iter -> int -> bool = "ml_gtk_text_iter_backward_lines"
  external forward_word_end : text_iter -> bool = "ml_gtk_text_iter_forward_word_end"
  external forward_word_ends : text_iter -> int -> bool = "ml_gtk_text_iter_forward_word_ends"
  external backward_word_start : text_iter -> bool = "ml_gtk_text_iter_backward_word_start"
  external backward_word_starts : text_iter -> int -> bool = "ml_gtk_text_iter_backward_word_starts"
  external forward_cursor_position : text_iter -> bool = "ml_gtk_text_iter_forward_cursor_position"
  external backward_cursor_position : text_iter -> bool = "ml_gtk_text_iter_backward_cursor_position"
  external forward_cursor_positions : text_iter -> int -> bool = "ml_gtk_text_iter_forward_cursor_positions"
  external backward_cursor_positions : text_iter -> int -> bool = "ml_gtk_text_iter_backward_cursor_positions"
  external forward_sentence_end : text_iter -> bool = "ml_gtk_text_iter_forward_sentence_end"
  external backward_sentence_start : text_iter -> bool = "ml_gtk_text_iter_backward_sentence_start"
  external forward_sentence_ends : text_iter -> int -> bool = "ml_gtk_text_iter_forward_sentence_ends"
  external backward_sentence_starts : text_iter -> int -> bool = "ml_gtk_text_iter_backward_sentence_starts"
  external set_offset : text_iter -> int -> unit = "ml_gtk_text_iter_set_offset"
  external set_line : text_iter -> int -> unit = "ml_gtk_text_iter_set_line"
  external set_line_offset : text_iter -> int -> unit = "ml_gtk_text_iter_set_line_offset"
  external set_line_index : text_iter -> int -> unit = "ml_gtk_text_iter_set_line_index"
  external set_visible_line_index : text_iter -> int -> unit = "ml_gtk_text_iter_set_visible_line_index"
  external set_visible_line_offset : text_iter -> int -> unit = "ml_gtk_text_iter_set_visible_line_offset"
  external forward_to_end : text_iter -> unit = "ml_gtk_text_iter_forward_to_end"
  external forward_to_line_end : text_iter -> bool = "ml_gtk_text_iter_forward_to_line_end"
  external forward_to_tag_toggle : text_iter -> text_tag option -> bool = "ml_gtk_text_iter_forward_to_tag_toggle"
  external backward_to_tag_toggle : text_iter -> text_tag option -> bool = "ml_gtk_text_iter_backward_to_tag_toggle"
  external equal : text_iter -> text_iter -> bool = "ml_gtk_text_iter_equal"
  external compare : text_iter -> text_iter -> int = "ml_gtk_text_iter_compare"
  external in_range : text_iter -> text_iter -> text_iter -> bool = "ml_gtk_text_iter_in_range"
  external order : text_iter -> text_iter -> unit = "ml_gtk_text_iter_order"

  external forward_search :
    text_iter -> string -> ?flags:text_search_flag list ->
    text_iter option -> (text_iter * text_iter) option 
    = "ml_gtk_text_iter_forward_search"
  external backward_search :
    text_iter -> string -> ?flags:text_search_flag list ->
    text_iter option -> (text_iter * text_iter) option 
    = "ml_gtk_text_iter_backward_search"
  external forward_find_char : 
    text_iter -> (Glib.unichar -> bool) -> text_iter option -> bool
      = "ml_gtk_text_iter_forward_find_char"
  external backward_find_char : 
    text_iter -> (Glib.unichar -> bool) -> text_iter option -> bool
      = "ml_gtk_text_iter_backward_find_char"
end
