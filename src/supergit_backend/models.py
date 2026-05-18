"""SuperGit-Tools Backend - Data Models"""
from dataclasses import dataclass, asdict
from typing import Optional
from enum import Enum
import json


class RepoStatus(str, Enum):
    """Repository status enumeration"""
    CLEAN = "Clean"
    DIRTY = "Dirty"
    AHEAD = "Ahead"
    BEHIND = "Behind"
    DIVERGED = "Diverged"
    ERROR = "Error"
    SYNCED = "Synced"
    SYNCING = "Syncing"
    PENDING = "Pending"


class SyncOp(str, Enum):
    """Sync operation types"""
    FETCH = "fetch"
    PULL = "pull"
    BOTH = "both"


@dataclass
class RepositoryInfo:
    """Repository information"""
    path: str
    name: str
    branch: str = "unknown"
    status: str = "Pending"
    is_dirty: bool = False
    ahead: int = 0
    behind: int = 0
    detailed_status: str = "Checking..."
    error: Optional[str] = None

    def to_json(self):
        """Convert to JSON string"""
        data = asdict(self)
        data['status'] = str(data['status'])
        return json.dumps(data)

    @classmethod
    def from_json(cls, json_str: str):
        """Create from JSON string"""
        data = json.loads(json_str)
        return cls(**data)


@dataclass
class SyncResult:
    """Sync operation result"""
    path: str
    success: bool
    status: str = "Unknown"
    error: Optional[str] = None
    output: str = ""
    timestamp: str = ""

    def to_json(self):
        """Convert to JSON string"""
        return json.dumps(asdict(self))

    @classmethod
    def from_json(cls, json_str: str):
        """Create from JSON string"""
        data = json.loads(json_str)
        return cls(**data)
