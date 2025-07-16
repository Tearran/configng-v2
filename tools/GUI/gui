#!/usr/bin/env python3

import tkinter as tk
from tkinter import ttk, messagebox
import json
import os

JSON_FILE = "modules_metadata.json"  # Put your JSON here

def load_json():
    try:
        with open(JSON_FILE, "r") as f:
            return json.load(f)
    except Exception as e:
        messagebox.showerror("Error", f"Could not load {JSON_FILE}:\n{e}")
        return {}

class ModernModuleBrowser(tk.Tk):
    def __init__(self, data):
        super().__init__()
        self.title("ConfigNG-v2 Module Browser")
        self.geometry("900x540")
        self.data = data

        # Main layout: sidebar (tree), details
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(1, weight=1)

        self.tree = ttk.Treeview(self, show="tree")
        self.tree.grid(row=0, column=0, sticky="nsw", padx=(12,0), pady=10, ipadx=6)
        self.tree.bind("<<TreeviewSelect>>", self.on_select)

        self.details = tk.Text(self, wrap="word", font=("Consolas", 12), width=60)
        self.details.grid(row=0, column=1, sticky="nsew", padx=(10,15), pady=10)

        # Styling
        style = ttk.Style(self)
        if "clam" in style.theme_names():
            style.theme_use("clam")
        style.configure("Treeview", font=("Segoe UI", 11), rowheight=28)
        style.configure("Treeview.Heading", font=("Segoe UI", 12, "bold"))

        self.populate_tree()

    def populate_tree(self):
        for cat in self.data:
            cat_id = self.tree.insert("", "end", text=cat, open=False)
            for group in self.data[cat]:
                group_id = self.tree.insert(cat_id, "end", text=group, open=False)
                for feature in self.data[cat][group]:
                    mod = self.data[cat][group][feature]
                    label = f"{mod.get('feature', feature)}"
                    self.tree.insert(group_id, "end", text=label, values=(cat, group, feature))

    def on_select(self, event):
        selected = self.tree.focus()
        vals = self.tree.item(selected, "values")
        self.details.delete("1.0", tk.END)
        if len(vals) == 3:  # Feature node
            cat, group, feature = vals
            mod = self.data[cat][group][feature]
            self.display_module(mod)
        elif len(vals) == 2:  # Group node (optional)
            pass
        elif len(vals) == 1:  # Category node
            pass

    def display_module(self, mod):
        self.details.insert(tk.END, f"{mod.get('feature', '')}\n", "title")
        if mod.get('description'):
            self.details.insert(tk.END, f"\n{mod['description']}\n", "desc")
        if mod.get('extend_desc'):
            self.details.insert(tk.END, f"\n{mod['extend_desc']}\n", "desc2")
        if mod.get('options'):
            self.details.insert(tk.END, f"\nOptions: {mod['options']}\n", "options")
        self.details.insert(tk.END, "\nRaw data:\n" + json.dumps(mod, indent=2), "raw")
        self.details.tag_configure("title", font=("Segoe UI", 14, "bold"))
        self.details.tag_configure("desc", font=("Segoe UI", 11))
        self.details.tag_configure("desc2", font=("Segoe UI", 10, "italic"))
        self.details.tag_configure("options", font=("Segoe UI", 11, "bold"), foreground="#297")
        self.details.tag_configure("raw", font=("Consolas", 9), foreground="#888")

if __name__ == "__main__":
    data = load_json()
    if data:
        app = ModernModuleBrowser(data)
        app.mainloop()