(* $Id$ *)

open Misc
open Gtk
open GtkBase
open GObj
open GData

class focus obj = object
  val obj = obj
  method circulate = Container.focus obj
  method set (child : widget option) =
    let child = may_map child fun:(fun x -> x#as_widget) in
    Container.set_focus_child obj (optboxed child)
  method set_hadjustment adj =
    Container.set_focus_hadjustment obj (optboxed (adjustment_option adj))
  method set_vadjustment adj =
    Container.set_focus_vadjustment obj (optboxed (adjustment_option adj))
end

class container obj = object
  inherit widget obj
  method add (w : widget) =
    Container.add obj w#as_widget
  method remove (w : widget) =
    Container.remove obj w#as_widget
  method children = List.map fun:(new widget_full) (Container.children obj)
  method set_border_width = Container.set_border_width obj
  method focus = new focus obj
end

class container_signals obj = object
  inherit widget_signals obj
  method add :callback =
    GtkSignal.connect sig:Container.Signals.add obj :after
      callback:(fun w -> callback (new widget_full w))
  method remove :callback =
    GtkSignal.connect sig:Container.Signals.remove obj :after
      callback:(fun w -> callback (new widget_full w))
end

class container_full obj = object
  inherit container obj
  method connect = new container_signals obj
end

class virtual ['a] item_container obj = object (self)
  inherit widget obj
  method add (w : 'a) =
    Container.add obj w#as_item
  method remove (w : 'a) =
    Container.remove obj w#as_item
  method private virtual wrap : Gtk.widget obj -> 'a
  method children : 'a list =
    List.map fun:self#wrap (Container.children obj)
  method set_border_width = Container.set_border_width obj
  method focus = new focus obj
  method virtual insert : 'a -> pos:int -> unit
  method append (w : 'a) = self#insert w pos:(-1)
  method prepend (w : 'a) = self#insert w pos:0
end

class item_signals obj = object
  inherit container_signals obj
  method select = GtkSignal.connect sig:Item.Signals.select obj :after
  method deselect = GtkSignal.connect sig:Item.Signals.deselect obj :after
  method toggle = GtkSignal.connect sig:Item.Signals.toggle obj :after
end
