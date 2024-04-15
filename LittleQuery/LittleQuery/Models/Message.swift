//
//  Message.swift
//  LittleQuery
//
//  Created by 한유진 on 4/15/24.
//

import Foundation

/*
 {
     "model": "gpt-3.5-turbo-0125",
     "choices": [
         {
             "index": 0,
             "message": {
                 "role": "assistant",
                 "content": "{\n    \"message\": \"Hello, world!\"\n}"
             },
             "logprobs": null,
             "finish_reason": "stop"
         }
     ],
     "usage": {
         "prompt_tokens": 20,
         "completion_tokens": 11,
         "total_tokens": 31
     },
 }
 */

/*
 {
   "prompt": {
     "task": "Study the behavior of dogs",
     "action": "Observe social interactions within a pack of dogs"
   },
   "question": "How do different dogs within a pack interact with each other, and what patterns can be observed in their social behavior?"
 }
 */
struct ChatRoot: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let role: String
    let content: String
}

struct InitialContent: Codable {
    let prompt: Prompt
    let question: String
}

struct Prompt: Codable {
    let task: String
    let action: String
}
