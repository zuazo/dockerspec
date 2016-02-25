# TODO for Dockerspec

* [ ] Integrate with [Inspec](https://www.chef.io/inspec/).
* [x] Integrate with [Infrataster](https://github.com/ryotarai/infrataster).
* [x] Support Docker Compose.
* [ ] Test resources for built images supported inside `docker_compose`.
* [ ] Add `docker_context`, `docker_describe` to avoid starting all containers at the same time.
* [ ] Add a Runner logger.
* [ ] Create `stub_*` methods for unit tests.
* [x] Add integration tests for Runner without Serverspec.
* [ ] Add a Capybara test example.
* [x] Fix `:env` with docker_run and Serverspec.
* [x] `have_expose` with int allowed
* [ ] Add `described_image` helper for `docker_run`.
* [ ] Rename the event methods in the Engines to be more clear.
