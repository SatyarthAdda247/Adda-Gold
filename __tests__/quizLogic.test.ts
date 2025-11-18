import { createQuizProgress, updateFeedStats } from "@store/quizLogic";
import { FeedProgress, QuizItem } from "@app/types/content";

const sampleQuiz: QuizItem = {
  id: "1",
  category: "SSC",
  difficulty: "medium",
  question: "Sample question?",
  options: {
    A: "Option A",
    B: "Option B",
    C: "Option C",
    D: "Option D",
  },
  correct: "B",
  explanation: "Because B is correct.",
};

const baseStats: FeedProgress = {
  answered: 3,
  correct: 2,
  streak: 1,
  totalTimeMs: 4200,
  lastSeenIndex: 2,
};

describe("quizLogic", () => {
  it("creates quiz progress with correctness flag", () => {
    const progress = createQuizProgress(sampleQuiz, "B", 1550, 1234567890);
    expect(progress).toEqual({
      quizId: "1",
      selected: "B",
      isCorrect: true,
      elapsedMs: 1550,
      answeredAt: 1234567890,
    });
  });

  it("marks incorrect answers appropriately", () => {
    const progress = createQuizProgress(sampleQuiz, "A", 980, 42);
    expect(progress.isCorrect).toBe(false);
    expect(progress.selected).toBe("A");
  });

  it("updates feed stats with a correct answer", () => {
    const updated = updateFeedStats(baseStats, true, 1200, 3);
    expect(updated).toEqual({
      answered: 4,
      correct: 3,
      streak: 2,
      totalTimeMs: 5400,
      lastSeenIndex: 3,
    });
  });

  it("resets streak when answer is incorrect", () => {
    const updated = updateFeedStats(baseStats, false, 1600, 4);
    expect(updated.streak).toBe(0);
    expect(updated.answered).toBe(baseStats.answered + 1);
    expect(updated.correct).toBe(baseStats.correct);
    expect(updated.totalTimeMs).toBe(baseStats.totalTimeMs + 1600);
    expect(updated.lastSeenIndex).toBe(4);
  });
});

