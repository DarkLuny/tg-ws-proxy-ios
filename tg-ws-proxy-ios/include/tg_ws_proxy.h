#ifndef TG_WS_PROXY_H
#define TG_WS_PROXY_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

int StartProxy(const char* host, int port, const char* dcIps, const char* secret, int verbose);
int StopProxy(void);
void SetPoolSize(int size);
void SetCfProxyCacheDir(const char* cacheDir);
void SetCfProxyConfig(int enabled, int priority, const char* userDomain);
void SetSecret(const char* secret);
void SetFakeTls(int enabled, const char* domain);
char* GetSecretWithPrefix(void);
char* GetStats(void);
void FreeString(char* p);

#ifdef __cplusplus
}
#endif

#endif /* TG_WS_PROXY_H */
