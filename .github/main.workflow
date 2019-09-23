workflow "Lint" {
  on = "push"
  resolves = ["swiftlint"]
}
	
action "swiftlint" {
  uses = "norio-nomura/action-swiftlint@master"
  secrets = ["ACCESS_TOKEN"]
}