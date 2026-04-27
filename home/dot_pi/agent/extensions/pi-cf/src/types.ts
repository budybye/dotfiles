export interface ModelDef {
  id: string;
  name: string;
  provider: "openai" | "anthropic" | "google";
  contextWindow: number;
  maxTokens: number;
  input: ("text" | "image")[];
  reasoning?: boolean;
  zdrSupported?: boolean;
  cost: {
    input: number;
    output: number;
    cacheRead?: number;
    cacheWrite?: number;
  };
  compat: {
    supportsDeveloperRole: boolean;
    maxTokensField: "max_tokens" | "max_completion_tokens";
    thinkingFormat?: "openai";
  };
}

export interface WorkersAiModelDef {
  id: string;
  name: string;
  contextWindow: number;
  maxTokens: number;
  input: ("text" | "image")[];
  reasoning?: boolean;
  cost: { input: number; output: number };
  compat: {
    supportsDeveloperRole: boolean;
    maxTokensField: "max_tokens" | "max_completion_tokens";
  };
}

export interface Config {
  accountId: string;
  gatewayName: string;
  apiToken: string;
  zdrEnabled?: boolean;
  customModels?: ModelDef[];
  defaultHeaders?: Record<string, string>;
  workersAi?: {
    enabled?: boolean;
    customModels?: WorkersAiModelDef[];
  };
}
