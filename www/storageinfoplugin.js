var exec = require('cordova/exec');

var storageinfoPlugin = {
    // Get storage information (total, free, used space)
    getStorageInfo: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'StorageInfoPlugin', 'getStorageInfo', []);
    },
    
    // Get app size information (app, data, cache)
    getAppSize: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'StorageInfoPlugin', 'getAppSize', []);
    },
    
    // Get all information (storage + app)
    getAllInfo: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'StorageInfoPlugin', 'getAllInfo', []);
    }
};

module.exports = storageinfoPlugin;