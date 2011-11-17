## 0.2.0

* Added the Camayoc::Stats#event method to do general event logging
* Refactored handler event propagation; handlers now implement an event(stat_event) method instead of count and timing
* Logging and IO handler formatter Procs now take a single StatEvent as an argument

## 0.1.0

* Initial release