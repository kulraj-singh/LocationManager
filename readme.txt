fetch user location with all cases handled
previously fetched location is stored in user defaults and we can use that if next time location fetch fails.

usage:

in your view controller
declare instance variable/property of LocationManager instance.
initialise and assign delegate.
And just call startFetchingLocation