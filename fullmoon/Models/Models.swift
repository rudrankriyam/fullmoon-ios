//
//  Models.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/4/24.
//

import Foundation
import MLXLMCommon
import MLXLLM

public extension ModelConfiguration {
    enum ModelType {
        case regular, reasoning
    }

    var modelType: ModelType {
        // All Qwen models are marked as reasoning type
        return .reasoning
    }
}

extension ModelConfiguration {
    public static func == (lhs: MLXLMCommon.ModelConfiguration, rhs: MLXLMCommon.ModelConfiguration) -> Bool {
        return lhs.name == rhs.name
    }

    public static var availableModels: [ModelConfiguration] = [
        LLMRegistry.qwen3_0_6b_4bit,
        LLMRegistry.qwen3_1_7b_4bit,
        LLMRegistry.qwen3_4b_4bit,
        LLMRegistry.qwen3_8b_4bit
    ]

    public static var defaultModel: ModelConfiguration {
        LLMRegistry.qwen3_1_7b_4bit
    }

    public static func getModelByName(_ name: String) -> ModelConfiguration? {
        if let model = availableModels.first(where: { $0.name == name }) {
            return model
        } else {
            return nil
        }
    }

    func getPromptHistory(thread: Thread, systemPrompt: String) -> [[String: String]] {
        var history: [[String: String]] = []

        // system prompt
        history.append([
            "role": "system",
            "content": systemPrompt,
        ])

        // messages
        for message in thread.sortedMessages {
            let role = message.role.rawValue
            history.append([
                "role": role,
                "content": formatForTokenizer(message.content), // Remove think tags and add a space before each message to fix the Jinja chat template issue.
            ])
        }

        return history
    }

    // TODO: Remove this function when Jinja gets updated
    func formatForTokenizer(_ message: String) -> String {
        if self.modelType == .reasoning {
            return " " + message
                .replacingOccurrences(of: "<think>", with: "")
                .replacingOccurrences(of: "</think>", with: "")
        }
        
        return message
    }

//    /// Returns the model's approximate size, in GB.
//    public var modelSize: Decimal? {
//        switch self {
//        case .llama_3_2_1b_4bit: return 0.7
//        case .llama_3_2_3b_4bit: return 1.8
//        case .deepseek_r1_distill_qwen_1_5b_4bit: return 1.0
//        case .deepseek_r1_distill_qwen_1_5b_8bit: return 1.9
//        default: return nil
//        }
//    }
}
