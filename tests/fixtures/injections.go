package main

func main() {
	seed := 0
	// sql
	query := `SELECT * FROM users`
	// sql
	plan := `EXPLAIN SELECT * FROM users`
	_, _, _ = seed, query, plan
}
