contract DeprecationSafe {
    bool public deprecated;

    modifier safelyDeprecates {
        if (deprecated) throw;
        _
    }
}
