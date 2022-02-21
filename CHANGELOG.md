# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.1] - 2022-10-01

### Removed
- Removed the necessity to require the new yaml source in your app #89


## [2.2.0] - 2021-16-12

### Added
- Added Ruby 3.0 compatibility #85
- Add manifest source option (#88), that enables application to use manifest from different sources


## [2.1.1] - 2021-07-01
- Fix bug when configuring cache_key to nil would load MemoryStore by default. It returns NullStore now. This bug only affected users configuring cache_store to nil.
- Configure cache_keys correctly

## [2.1.0] - 2021-06-30
- Add integration with ActionSupport::Cache's stores. As rollouts don't change often, adding a cache can save thousands of calls to the storage. It's possible to configure the same way Rails allows cache_stores to be configured.

  configuration.cache_store = :memory_store, { expires_in: 100 }

  Additionally, we also added an option to skip the cache entirely by adding a `skip_cache: true` on FF methods. Example:

  Account.released_id?(resource_id, key, skip_local_cache: true)

  By default there is no cache configured.

## [2.0.1] - 2021-01-27

- Reverted 2.0.0 because of some issues with Redis Keys.

## [2.0.0] - 2020-06-15

* This version has some issues with Redis Keys. Use version 2.0.1 or 1.2.1.*

### Added
- A new structure of data inside Storage::Redis #60
- This CHANGELOG file to hopefully serve as an evolving example of a
  standardized open-source project CHANGELOG.
- New `Model#releases` method, which will return all the features accessible by the `Model`

### Breaking Changes
- The main API of `FeatureFlagger::Control` and `FeatureFlagger::Storage`
  got rewritten, we decoupled the `resource_name` from the `feature_key`
  and that allowed us to change the way we store the data

## [1.2.1] - 2020-08-10
### Added
- Fix bug in Migration script and `.releases` interface #72

## [1.2.0] - 2020-08-03
### Added
- Add the interface to fetch all features already released to a given resource #67
- This CHANGELOG file to hopefully serve as an evolving example of a
  standardized open-source project CHANGELOG.
- New `Model#releases` method, which will return all the features accessible by the `Model`

### Breaking Changes
- The main API of `FeatureFlagger::Storage` and `FeatureFlagger::Storage::Redis` got rewritten,
  we decoupled the `resource_name` from the `feature_key` and that allowed us to change the
  way we store the data to implement new features.
