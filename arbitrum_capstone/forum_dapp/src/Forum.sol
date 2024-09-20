// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Forum {
    // Part A - Create Struct for Post, Comment, and Poll
    struct Post {
        address owner;
        uint256 id;
        string title;
        string description;
        bool spoil;
        uint256 likes;
        uint256 timestamp;
    }

    struct Comment {
        address owner;
        uint256 id;
        string title;
        string description;
        bool spoil;
        uint256 likes;
        uint256 timestamp;
    }

    struct Poll {
        uint256 id;
        string question;
        string option1;
        string option2;
        uint256 option1Counter;
        uint256 option2Counter;
    }

    uint256 public postIdIncrement = 1;
    uint256 public pollIdIncrement = 1;
    uint256 public commentIdIncrement = 1;

    mapping(address => uint256[]) private userPosts; // each post ID assigned to the user
    mapping(uint256 => Post) public posts; // assign postId to posts
    mapping(uint256 => Poll) public polls; // assign pollId to poll
    mapping(uint256 => Comment) public comments; // assign commentId to comment

    mapping(uint256 => uint256) public postToPoll; // assign postId -> pollId
    mapping(uint256 => uint256[]) private postToComments; // assign postId -> commentId[]
    mapping(address => uint256[]) private userComments; // assign address to a list of comments
    mapping(address => uint256[]) private userPolls; // assign address to a list of polls

    event PostSubmitted(address indexed userAddress, Post post);

    // Part B - Write Create Post Function
    function createPost(string memory _title, string memory _description, bool _spoil) public returns (uint256) {
        uint256 postId = postIdIncrement++;
        posts[postId] = Post(msg.sender, postId, _title, _description, _spoil, 0, block.timestamp);
        userPosts[msg.sender].push(postId);
        emit PostSubmitted(msg.sender, posts[postId]);
        return postId;
    }

    // Part C - Write Create Poll Function
    function createPoll(uint256 _postId, string memory _question, string memory _option1, string memory _option2)
        public
        returns (uint256)
    {
        require(_postId < postIdIncrement, "Post does not exist!");
        uint256 pollId = pollIdIncrement++;
        polls[pollId] = Poll(pollId, _question, _option1, _option2, 0, 0);
        postToPoll[_postId] = pollId;
        userPolls[msg.sender].push(pollId);
        return pollId;
    }

    // Part D - Write Create Comment Function
    function createComment(uint256 _postId, string memory _title, string memory _description, bool _spoil)
        public
        returns (uint256)
    {
        require(_postId < postIdIncrement, "Post does not exist!");
        uint256 commentId = commentIdIncrement++;
        comments[commentId] = Comment(msg.sender, commentId, _title, _description, _spoil, 0, block.timestamp);
        postToComments[_postId].push(commentId);
        userComments[msg.sender].push(commentId);
        return commentId;
    }

    // Retrieve posts from an address
    function getPostsFromAddress(address _user) public view returns (uint256[] memory) {
        return userPosts[_user];
    }

    // Retrieve a specific post
    function getPost(uint256 _postId) public view returns (Post memory) {
        require(_postId < postIdIncrement, "Post does not exist!");
        return posts[_postId];
    }

    // Retrieve poll from a post
    function getPollFromPost(uint256 _postId) public view returns (Poll memory) {
        require(_postId < postIdIncrement, "Post does not exist!");
        uint256 _pollId = postToPoll[_postId];
        Poll memory poll = getPoll(_pollId);
        return poll;
    }

    // Retrieve a specific poll
    function getPoll(uint256 _pollId) public view returns (Poll memory) {
        require(_pollId < pollIdIncrement, "Poll does not exist!");
        return polls[_pollId];
    }

    // Retrieve a list of comments from a post
    function getCommentsFromPost(uint256 _postId) public view returns (uint256[] memory) {
        require(_postId < postIdIncrement, "Post does not exist!");
        return postToComments[_postId];
    }

    // Retrieve a specific comment
    function getComment(uint256 _commentId) public view returns (Comment memory) {
        require(_commentId < commentIdIncrement, "Comment does not exist!");
        return comments[_commentId];
    }

    // Upvote and downvote functionality for posts
    function upVotePost(uint256 _postId) public {
        require(_postId < postIdIncrement, "Post does not exist!");
        Post storage post = posts[_postId];
        post.likes += 1;
    }

    function downVotePost(uint256 _postId) public {
        require(_postId < postIdIncrement, "Post does not exist!");
        Post storage post = posts[_postId];
        post.likes -= 1;
    }

    // Upvote and downvote functionality for comments
    function upVoteComment(uint256 _commentId) public {
        require(_commentId < commentIdIncrement, "Comment does not exist!");
        Comment storage comment = comments[_commentId];
        comment.likes += 1;
    }

    function downVoteComment(uint256 _commentId) public {
        require(_commentId < commentIdIncrement, "Comment does not exist!");
        Comment storage comment = comments[_commentId];
        comment.likes -= 1;
    }

    // Upvote poll option for polls associated with posts
    function upVotePollOption(uint256 _postId, string memory option) public {
        require(_postId < postIdIncrement, "Post does not exist!");
        Poll storage poll = polls[postToPoll[_postId]];

        if (compareStringsbyBytes(poll.option1, option)) {
            poll.option1Counter++;
        } else if (compareStringsbyBytes(poll.option2, option)) {
            poll.option2Counter++;
        } else {
            revert("Not a valid option");
        }
    }

    // Compare two strings using keccak256 hashing
    function compareStringsbyBytes(string memory s1, string memory s2) public pure returns (bool) {
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }
}
