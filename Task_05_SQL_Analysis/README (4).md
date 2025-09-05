# Chinook SQL Analysis (PostgreSQL)

## Objective
Perform a comprehensive SQL analysis of the **Chinook** music store to uncover insights on **customers**, **sales & revenue**, **tracks/genres/playlists**, and **employee performance**. Deliver a clean SQL script, a structured insights report, and communication assets (LinkedIn post + portfolio description).

## Dataset / Schema
Tables used: `artists`, `albums`, `tracks`, `genres`, `media_types`, `playlists`, `playlisttrack`, `customers`, `employees`, `invoices`, `invoicelines`.

> If your database uses **CamelCase** identifiers (e.g., `"Artist"`, `"InvoiceLine"`), wrap names in double quotes and adjust column names accordingly.

## How to Run (PostgreSQL)
1. Ensure the Chinook DB is loaded into PostgreSQL (e.g., database name: `chinook`).
2. Save the SQL from this project as **`chinook_analysis.sql`**.
3. Run:
   ```bash
   psql -d chinook -f chinook_analysis.sql
   ```
4. For parameterized queries (e.g., co-purchases on a `:track_id`), replace **`:track_id`** with a concrete integer value before running.

## Deliverables
- **SQL:** `chinook_analysis.sql` (queries with comments and reusable CTEs)
- **Report:** `Chinook_Report.docx` (Word document with insights and recommendations)
- **README:** this file
- **LinkedIn Post Draft:** (provided in chat) to share methodology & learnings
- **Portfolio/Project Description:** (provided in chat) short blurb for GitHub/portfolio

## Notes
- The SQL includes optional **index suggestions** (commented) to improve performance on larger datasets.
- The report structure shows how to convert query outputs into actionable insights for stakeholders.
- If your schema/table names differ, update the SQL identifiers accordingly.
