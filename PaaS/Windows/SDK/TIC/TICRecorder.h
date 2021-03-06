#pragma once

#include <string>
#include <functional>
#include "TICManager.h"

class TICRecorder
{
public:
	void sendOfflineRecordInfo(const std::string& ntpServer, std::string groupId, TICCallback callback);
	void reportGroupId(bool bTest, int sdkappid, const std::string& userId, const std::string& userSig, const std::string& groupId);
};