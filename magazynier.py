import tkinter as tk
from tkinter import ttk, messagebox
import psycopg2
from psycopg2.extras import RealDictCursor

DB = dict(host="localhost", dbname="mydb", user="postgres", password="")


def connect():
    return psycopg2.connect(**DB, cursor_factory=RealDictCursor)

# wybor magazynu na start

class WarehousePicker(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Wybór magazynu")
        self.geometry("340x160")
        self.resizable(False, False)
        self.warehouse_id = None
        self.warehouse_name = None

        tk.Label(self, text="Wybierz magazyn:", font=("Arial", 12)).pack(pady=(24, 6))

        self._warehouses = self._load()
        names = [w["nazwa"] for w in self._warehouses]

        self._var = tk.StringVar(value=names[0] if names else "")
        self._combo = ttk.Combobox(self, textvariable=self._var, values=names,
                                    state="readonly", width=36)
        self._combo.pack(pady=4)

        tk.Button(self, text="Otwórz", width=14, command=self._confirm).pack(pady=14)

    def _load(self):
        with connect() as conn, conn.cursor() as cur:
            cur.execute("SELECT id_magazyn, nazwa FROM magazyn ORDER BY nazwa")
            return cur.fetchall()

    def _confirm(self):
        name = self._var.get()
        for w in self._warehouses:
            if w["nazwa"] == name:
                self.warehouse_id = w["id_magazyn"]
                self.warehouse_name = w["nazwa"]
                break
        self.destroy()


#app

class App(tk.Tk):
    def __init__(self, warehouse_id, warehouse_name):
        super().__init__()
        self.wid = warehouse_id
        self.title(f"Magazynier — {warehouse_name}")
        self.geometry("860x560")

        notebook = ttk.Notebook(self)
        notebook.pack(fill="both", expand=True, padx=8, pady=8)

        self._tab_stock   = tk.Frame(notebook)
        self._tab_update  = tk.Frame(notebook)
        self._tab_sup     = tk.Frame(notebook)
        self._tab_plants  = tk.Frame(notebook)

        notebook.add(self._tab_stock,  text="Stan magazynu")
        notebook.add(self._tab_update, text="Aktualizacja stanu")
        notebook.add(self._tab_sup,    text="Dostawcy")
        notebook.add(self._tab_plants, text="Oczyszczalnie w regionie")

        self._build_stock_tab()
        self._build_update_tab()
        self._build_suppliers_tab()
        self._build_plants_tab()

    def _make_tree(self, parent, columns):
        frame = tk.Frame(parent)
        frame.pack(fill="both", expand=True, padx=6, pady=4)

        tree = ttk.Treeview(frame, columns=columns, show="headings", height=8)
        for col in columns:
            tree.heading(col, text=col)
            tree.column(col, width=180, anchor="w")

        vsb = ttk.Scrollbar(frame, orient="vertical", command=tree.yview)
        tree.configure(yscrollcommand=vsb.set)
        tree.pack(side="left", fill="both", expand=True)
        vsb.pack(side="right", fill="y")
        return tree

    # tab 1 stan magazynu

    def _build_stock_tab(self):
        p = self._tab_stock

        tk.Label(p, text="Reagenty", font=("Arial", 10, "bold")).pack(anchor="w", padx=6, pady=(6, 0))
        self._tree_reagent = self._make_tree(p, ("Reagent", "Typ", "Ilość"))
        self._load_reagents()

        tk.Label(p, text="Czujniki", font=("Arial", 10, "bold")).pack(anchor="w", padx=6, pady=(6, 0))
        self._tree_czujnik = self._make_tree(p, ("Typ czujnika", "Ilość (szt.)"))
        self._load_sensors()

        tk.Label(p, text="Sterowniki", font=("Arial", 10, "bold")).pack(anchor="w", padx=6, pady=(6, 0))
        self._tree_sterownik = self._make_tree(p, ("Typ sterownika", "Ilość (szt.)"))
        self._load_controllers()

        tk.Label(p, text="Elementy wykonawcze", font=("Arial", 10, "bold")).pack(anchor="w", padx=6, pady=(6, 0))
        self._tree_element = self._make_tree(p, ("Typ elementu", "Ilość (szt.)"))
        self._load_actuators()

    def _fill_tree(self, tree, rows):
        tree.delete(*tree.get_children())
        for row in rows:
            tree.insert("", "end", values=tuple(v if v is not None else "—" for v in row))

    def _load_reagents(self):
        with connect() as conn, conn.cursor() as cur:
            cur.execute("""
                SELECT r.nazwa, tr.nazwa, mr.wolumen
                FROM magazyn_reagent mr
                JOIN reagent r ON r.id_reagent = mr.id_reagent
                JOIN typ_reagenta tr ON tr.id_typ_reagenta = r.id_typ_reagenta
                WHERE mr.id_magazyn = %s ORDER BY r.nazwa
            """, (self.wid,))
            self._fill_tree(self._tree_reagent, [(r["nazwa"], r["typ_reagenta"] if "typ_reagenta" in r else list(r.values())[1], r["wolumen"]) for r in cur.fetchall()])

    def _load_sensors(self):
        with connect() as conn, conn.cursor() as cur:
            cur.execute("""
                SELECT tc.nazwa, mc.ilosc
                FROM magazyn_czujnik mc
                JOIN czujnik c ON c.id_czujnik = mc.id_czujnik
                JOIN typ_czujnika tc ON tc.id_typ_czujnika = c.id_typ_czujnika
                WHERE mc.id_magazyn = %s ORDER BY tc.nazwa
            """, (self.wid,))
            self._fill_tree(self._tree_czujnik, [(r["nazwa"], r["ilosc"]) for r in cur.fetchall()])

    def _load_controllers(self):
        with connect() as conn, conn.cursor() as cur:
            cur.execute("""
                SELECT ts.nazwa, ms.ilosc
                FROM magazyn_sterownik ms
                JOIN sterownik s ON s.id_sterownik = ms.id_sterownik
                JOIN typ_sterownika ts ON ts.id_typ_sterownika = s.id_typ_sterownika
                WHERE ms.id_magazyn = %s ORDER BY ts.nazwa
            """, (self.wid,))
            self._fill_tree(self._tree_sterownik, [(r["nazwa"], r["ilosc"]) for r in cur.fetchall()])

    def _load_actuators(self):
        with connect() as conn, conn.cursor() as cur:
            cur.execute("""
                SELECT te.nazwa, me.ilosc
                FROM magazyn_element_wykonawczy me
                JOIN element_wykonawczy e ON e.id_element_wykonawczy = me.id_element_wykonawczy
                JOIN typ_elementu_wykonawczego te ON te.id_typ_elementu_wykonawczego = e.id_typ_elementu_wykonawczego
                WHERE me.id_magazyn = %s ORDER BY te.nazwa
            """, (self.wid,))
            self._fill_tree(self._tree_element, [(r["nazwa"], r["ilosc"]) for r in cur.fetchall()])

    # tab 2 aktualizuj stan magazynu

    def _build_update_tab(self):
        p = self._tab_update

        tk.Label(p, text="Kategoria:").grid(row=0, column=0, padx=12, pady=(20, 6), sticky="w")
        self._cat_var = tk.StringVar(value="Reagent")
        cat_combo = ttk.Combobox(p, textvariable=self._cat_var, state="readonly", width=30,
                                  values=["Reagent", "Czujnik", "Sterownik", "Element wykonawczy"])
        cat_combo.grid(row=0, column=1, padx=12, pady=(20, 6), sticky="w")
        cat_combo.bind("<<ComboboxSelected>>", lambda e: self._on_cat_change())

        tk.Label(p, text="Pozycja:").grid(row=1, column=0, padx=12, pady=6, sticky="w")
        self._item_var = tk.StringVar()
        self._item_combo = ttk.Combobox(p, textvariable=self._item_var, state="readonly", width=30)
        self._item_combo.grid(row=1, column=1, padx=12, pady=6, sticky="w")

        tk.Label(p, text="Nowa ilość:").grid(row=2, column=0, padx=12, pady=6, sticky="w")
        self._qty_var = tk.StringVar()
        tk.Entry(p, textvariable=self._qty_var, width=32).grid(row=2, column=1, padx=12, pady=6, sticky="w")

        tk.Button(p, text="Zapisz", width=14, command=self._save_qty).grid(row=3, column=1, padx=12, pady=14, sticky="w")

        self._msg_var = tk.StringVar()
        tk.Label(p, textvariable=self._msg_var, fg="green").grid(row=4, column=1, padx=12, sticky="w")

        self._items_cache = {}
        self._on_cat_change()

    def _on_cat_change(self):
        cat = self._cat_var.get()
        with connect() as conn, conn.cursor() as cur:
            if cat == "Reagent":
                cur.execute("""
                    SELECT mr.id_reagent AS iid, r.nazwa AS label, mr.wolumen AS qty
                    FROM magazyn_reagent mr JOIN reagent r ON r.id_reagent = mr.id_reagent
                    WHERE mr.id_magazyn = %s ORDER BY r.nazwa
                """, (self.wid,))
            elif cat == "Czujnik":
                cur.execute("""
                    SELECT mc.id_czujnik AS iid, tc.nazwa AS label, mc.ilosc AS qty
                    FROM magazyn_czujnik mc JOIN czujnik c ON c.id_czujnik = mc.id_czujnik
                    JOIN typ_czujnika tc ON tc.id_typ_czujnika = c.id_typ_czujnika
                    WHERE mc.id_magazyn = %s ORDER BY tc.nazwa
                """, (self.wid,))
            elif cat == "Sterownik":
                cur.execute("""
                    SELECT ms.id_sterownik AS iid, ts.nazwa AS label, ms.ilosc AS qty
                    FROM magazyn_sterownik ms JOIN sterownik s ON s.id_sterownik = ms.id_sterownik
                    JOIN typ_sterownika ts ON ts.id_typ_sterownika = s.id_typ_sterownika
                    WHERE ms.id_magazyn = %s ORDER BY ts.nazwa
                """, (self.wid,))
            else:
                cur.execute("""
                    SELECT me.id_element_wykonawczy AS iid, te.nazwa AS label, me.ilosc AS qty
                    FROM magazyn_element_wykonawczy me
                    JOIN element_wykonawczy e ON e.id_element_wykonawczy = me.id_element_wykonawczy
                    JOIN typ_elementu_wykonawczego te ON te.id_typ_elementu_wykonawczego = e.id_typ_elementu_wykonawczego
                    WHERE me.id_magazyn = %s ORDER BY te.nazwa
                """, (self.wid,))
            rows = cur.fetchall()

        self._items_cache = {r["label"]: (r["iid"], r["qty"]) for r in rows}
        labels = list(self._items_cache.keys())
        self._item_combo["values"] = labels
        if labels:
            self._item_var.set(labels[0])
            self._qty_var.set(str(self._items_cache[labels[0]][1]))
        self._msg_var.set("")

    def _save_qty(self):
        cat = self._cat_var.get()
        label = self._item_var.get()
        if not label or label not in self._items_cache:
            self._msg_var.set("Wybierz pozycję.")
            return
        try:
            qty = float(self._qty_var.get())
            if qty < 0:
                raise ValueError
        except ValueError:
            self._msg_var.set("Podaj poprawną nieujemną liczbę.")
            return

        iid = self._items_cache[label][0]
        with connect() as conn, conn.cursor() as cur:
            if cat == "Reagent":
                cur.execute("UPDATE magazyn_reagent SET wolumen=%s WHERE id_magazyn=%s AND id_reagent=%s",
                            (qty, self.wid, iid))
            elif cat == "Czujnik":
                cur.execute("UPDATE magazyn_czujnik SET ilosc=%s WHERE id_magazyn=%s AND id_czujnik=%s",
                            (int(qty), self.wid, iid))
            elif cat == "Sterownik":
                cur.execute("UPDATE magazyn_sterownik SET ilosc=%s WHERE id_magazyn=%s AND id_sterownik=%s",
                            (int(qty), self.wid, iid))
            else:
                cur.execute("UPDATE magazyn_element_wykonawczy SET ilosc=%s WHERE id_magazyn=%s AND id_element_wykonawczy=%s",
                            (int(qty), self.wid, iid))
            conn.commit()

        self._msg_var.set(f"Zapisano: {label} → {qty}")
        self._on_cat_change()
        self._load_reagents()
        self._load_sensors()
        self._load_controllers()
        self._load_actuators()

    # tab 3 przegladanie dostawcow

    def _build_suppliers_tab(self):
        p = self._tab_sup

        top = tk.Frame(p)
        top.pack(fill="x", padx=6, pady=(12, 4))
        tk.Label(top, text="Dostawca:").pack(side="left", padx=(0, 6))

        with connect() as conn, conn.cursor() as cur:
            cur.execute("SELECT id_dostawca, nazwa, adres FROM dostawca ORDER BY nazwa")
            self._suppliers = cur.fetchall()

        self._sup_var = tk.StringVar()
        sup_combo = ttk.Combobox(top, textvariable=self._sup_var, state="readonly", width=36,
                                  values=[s["nazwa"] for s in self._suppliers])
        sup_combo.pack(side="left")
        sup_combo.bind("<<ComboboxSelected>>", lambda e: self._on_sup_change())

        self._sup_info = tk.Label(p, text="", anchor="w", justify="left")
        self._sup_info.pack(anchor="w", padx=8, pady=4)

        self._tree_sup = self._make_tree(p, ("Kategoria", "Pozycja", "Cena (PLN)", "Czas dostawy (dni)"))

        if self._suppliers:
            self._sup_var.set(self._suppliers[0]["nazwa"])
            self._on_sup_change()

    def _on_sup_change(self):
        name = self._sup_var.get()
        sup = next((s for s in self._suppliers if s["nazwa"] == name), None)
        if not sup:
            return
        sid = sup["id_dostawca"]
        self._sup_info.config(text=f"Adres: {sup['adres'] or '—'}")

        rows = []
        with connect() as conn, conn.cursor() as cur:
            cur.execute("""
                SELECT 'Reagent' AS kat, r.nazwa, dr.cena, dr.czas_oczekiwania_dni
                FROM dostawca_reagent dr JOIN reagent r ON r.id_reagent = dr.id_reagent
                WHERE dr.id_dostawca = %s
            """, (sid,))
            rows += [(r["kat"], r["nazwa"], r["cena"], r["czas_oczekiwania_dni"]) for r in cur.fetchall()]

            cur.execute("""
                SELECT 'Czujnik' AS kat, tc.nazwa, dc.cena, dc.czas_oczekiwania_dni
                FROM dostawca_czujnik dc JOIN czujnik c ON c.id_czujnik = dc.id_czujnik
                JOIN typ_czujnika tc ON tc.id_typ_czujnika = c.id_typ_czujnika
                WHERE dc.id_dostawca = %s
            """, (sid,))
            rows += [(r["kat"], r["nazwa"], r["cena"], r["czas_oczekiwania_dni"]) for r in cur.fetchall()]

            cur.execute("""
                SELECT 'Sterownik' AS kat, ts.nazwa, ds.cena, ds.czas_oczekiwania_dni
                FROM dostawca_sterownik ds JOIN sterownik s ON s.id_sterownik = ds.id_sterownik
                JOIN typ_sterownika ts ON ts.id_typ_sterownika = s.id_typ_sterownika
                WHERE ds.id_dostawca = %s
            """, (sid,))
            rows += [(r["kat"], r["nazwa"], r["cena"], r["czas_oczekiwania_dni"]) for r in cur.fetchall()]

            cur.execute("""
                SELECT 'Element wykonawczy' AS kat, te.nazwa, de.cena, de.czas_oczekiwania_dni
                FROM dostawca_element_wykonawczy de
                JOIN element_wykonawczy e ON e.id_element_wykonawczy = de.id_element_wykonawczy
                JOIN typ_elementu_wykonawczego te ON te.id_typ_elementu_wykonawczego = e.id_typ_elementu_wykonawczego
                WHERE de.id_dostawca = %s
            """, (sid,))
            rows += [(r["kat"], r["nazwa"], r["cena"], r["czas_oczekiwania_dni"]) for r in cur.fetchall()]

        self._fill_tree(self._tree_sup, rows)

    # tab 4 przegladanie oczyszczalni w regionie

    def _build_plants_tab(self):
        p = self._tab_plants

        top = tk.Frame(p)
        top.pack(fill="x", padx=6, pady=(12, 4))
        tk.Label(top, text="Region:").pack(side="left", padx=(0, 6))

        with connect() as conn, conn.cursor() as cur:
            cur.execute("SELECT id_region, nazwa FROM region ORDER BY nazwa")
            self._regions = cur.fetchall()

        self._reg_var = tk.StringVar()
        reg_combo = ttk.Combobox(top, textvariable=self._reg_var, state="readonly", width=30,
                                  values=[r["nazwa"] for r in self._regions])
        reg_combo.pack(side="left")
        reg_combo.bind("<<ComboboxSelected>>", lambda e: self._on_reg_change())

        self._tree_plants = self._make_tree(p, ("Oczyszczalnia", "Zbiornik", "Reagent", "Aktualna ilość"))

        if self._regions:
            self._reg_var.set(self._regions[0]["nazwa"])
            self._on_reg_change()

    def _on_reg_change(self):
        reg = next((r for r in self._regions if r["nazwa"] == self._reg_var.get()), None)
        if not reg:
            return
        with connect() as conn, conn.cursor() as cur:
            cur.execute("""
                SELECT o.nazwa AS oczyszczalnia,
                       tz.nazwa AS zbiornik,
                       r.nazwa  AS reagent,
                       zr.aktualna_ilosc
                FROM oczyszczalnia o
                JOIN zbiornik z ON z.id_oczyszczalnia = o.id_oczyszczalnia
                JOIN typ_zbiornika tz ON tz.id_typ_zbiornika = z.id_typ_zbiornika
                JOIN zbiornik_reagent zr ON zr.id_zbiornik = z.id_zbiornik
                JOIN reagent r ON r.id_reagent = zr.id_reagent
                WHERE o.id_region = %s
                ORDER BY o.nazwa, tz.nazwa, r.nazwa
            """, (reg["id_region"],))
            rows = cur.fetchall()

        self._fill_tree(self._tree_plants,
                        [(r["oczyszczalnia"], r["zbiornik"], r["reagent"], r["aktualna_ilosc"]) for r in rows])


# main

if __name__ == "__main__":
    picker = WarehousePicker()
    picker.mainloop()

    if picker.warehouse_id is None:
        exit()

    app = App(picker.warehouse_id, picker.warehouse_name)
    app.mainloop()
