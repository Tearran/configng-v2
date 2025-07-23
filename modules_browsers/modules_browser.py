#!/usr/bin/env python3

import tkinter as tk
from tkinter import ttk, messagebox
import json
import os

JSON_FILE = "./modules_browsers/modules_metadata.json"  # Your JSON file path

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

		# Layout
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
		self.tree_nodes = {}  # Map node id to node data for lookup
		for cat in self.data.get("menu", []):
			cat_id = cat.get("id", "")
			cat_label = cat.get("id", "")
			cat_desc = cat.get("description", "")
			cat_node = self.tree.insert("", "end", text=cat_label, open=False)
			self.tree_nodes[cat_node] = {"level": "category", "data": cat, "label": cat_label, "description": cat_desc}

			for group in cat.get("sub", []):
				group_id = group.get("id", "")
				group_label = group.get("id", "")
				group_desc = group.get("description", "")
				group_node = self.tree.insert(cat_node, "end", text=group_label, open=False)
				self.tree_nodes[group_node] = {"level": "group", "data": group, "label": group_label, "description": group_desc, "parent_desc": cat_desc}

				for feature in group.get("sub", []):
					feature_id = feature.get("id", "")
					feature_label = feature.get("feature", "")
					feature_desc = feature.get("description", "")
					feature_node = self.tree.insert(group_node, "end", text=feature_label, values=(feature_id,))
					self.tree_nodes[feature_node] = {"level": "feature", "data": feature, "label": feature_label, "description": feature_desc, "parent_desc": group_desc}

	def on_select(self, event):
		selected = self.tree.focus()
		node = self.tree_nodes.get(selected)
		self.details.delete("1.0", tk.END)
		if not node:
			return

		level = node.get("level")
		data = node.get("data", {})
		label = node.get("label", "")
		desc = node.get("description", "")
		parent_desc = node.get("parent_desc", "")

		if level == "feature":
			self.display_module(data)
		elif level == "group":
			title = f"Group: {label}\n\n"
			self.details.insert(tk.END, title, "title")
			self.details.insert(tk.END, f"{desc}\n" if desc else "(No description)\n", "desc")
			if parent_desc:
				self.details.insert(tk.END, f"\nParent category: {parent_desc}\n", "catdesc")
			self.details.tag_configure("title", font=("Segoe UI", 14, "bold"))
			self.details.tag_configure("desc", font=("Segoe UI", 11))
			self.details.tag_configure("catdesc", font=("Segoe UI", 10, "italic"))
		elif level == "category":
			title = f"Category: {label}\n\n"
			self.details.insert(tk.END, title, "title")
			self.details.insert(tk.END, f"{desc}\n" if desc else "(No description)\n", "desc")
			self.details.tag_configure("title", font=("Segoe UI", 14, "bold"))
			self.details.tag_configure("desc", font=("Segoe UI", 11))

	def display_module(self, mod):
		self.details.insert(tk.END, f"{mod.get('feature', '')}\n", "title")
		if mod.get('description'):
			self.details.insert(tk.END, f"\n{mod['description']}\n", "desc")
		if mod.get('about'):
			self.details.insert(tk.END, f"\nAbout: {mod['about']}\n", "about")
		if mod.get('options'):
			self.details.insert(tk.END, f"\nOptions: {mod['options']}\n", "options")
		self.details.insert(tk.END, "\nRaw data:\n" + json.dumps(mod, indent=2), "raw")
		self.details.tag_configure("title", font=("Segoe UI", 14, "bold"))
		self.details.tag_configure("desc", font=("Segoe UI", 11))
		self.details.tag_configure("about", font=("Segoe UI", 10, "italic"))
		self.details.tag_configure("options", font=("Segoe UI", 11, "bold"), foreground="#297")
		self.details.tag_configure("raw", font=("Consolas", 9), foreground="#888")

if __name__ == "__main__":
	data = load_json()
	if data:
		app = ModernModuleBrowser(data)
		app.mainloop()