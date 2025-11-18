  const quizStats = useQuizStore((state) => state.stats);
  const reelStats = useReelStore((state) => state.stats);
  const reelBookmarks = useReelStore((state) => state.bookmarks);
  const reelLikes = useReelStore((state) => state.likes);
  const resetQuiz = useQuizStore((state) => state.resetProgress);
  const resetReels = useReelStore((state) => state.reset);
